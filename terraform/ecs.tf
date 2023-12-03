# SECURITY GROUP
resource "aws_security_group" "ecs" {
  name        = "${var.project}-ecs"
  description = "${var.project}-ecs"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
  }

  ingress {
    from_port        = 5000
    to_port          = 5000
    protocol         = "tcp"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project}-ecs"
  }
}

resource "aws_security_group_rule" "front_from_alb" {
  type                     = "ingress"
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  from_port                = 80
  security_group_id        = aws_security_group.ecs.id
}

resource "aws_security_group_rule" "gpt_from_alb" {
  type                     = "ingress"
  to_port                  = 5000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  from_port                = 5000
  security_group_id        = aws_security_group.ecs.id
}

# TASK
resource "aws_ecs_task_definition" "main" {
  depends_on = [aws_ecr_repository.front, aws_ecr_repository.gpt]

  family = var.project

  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"

  cpu = "2048"
  memory = "4096"

  execution_role_arn = var.ecs_task_execution_role

  container_definitions = jsonencode([
    {
      name      = "${var.project}-front"
      image     = aws_ecr_repository.front.repository_url
      cpu       = 1024
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    },
    {
      name      = "${var.project}-gpt"
      image     = aws_ecr_repository.gpt.repository_url
      cpu       = 1024
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ])
}

# CLUSTER
resource "aws_ecs_cluster" "main" {
  name = var.project
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = "FARGATE"
  }
}

# SERVICE
resource "aws_ecs_service" "main" {
  name            = var.project
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  network_configuration {
    subnets          = [var.subnet1, var.subnet2]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.front.arn
    container_name   = "${var.project}-front"
    container_port   = 3000
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.gpt.arn
    container_name   = "${var.project}-gpt"
    container_port   = 5000
  }
}