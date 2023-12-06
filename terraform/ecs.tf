# SECURITY GROUP
resource "aws_security_group" "ecs" {
  name        = "ai-typology-ecs"
  description = "ai-typology-ecs"
  vpc_id      = var.vpc_id

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
    Name = "ai-typology-ecs"
  }
}

resource "aws_security_group_rule" "main" {
  type                     = "ingress"
  to_port                  = 5000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  from_port                = 80
  security_group_id        = aws_security_group.ecs.id
}

# TASK
resource "aws_ecs_task_definition" "main" {
  depends_on = [aws_ecr_repository.main]

  family = "ai-typology"

  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"

  cpu = "2048"
  memory = "4096"

  execution_role_arn = var.ecs_task_execution_role

  container_definitions = jsonencode([
    {
      name      = "ai-typology"
      image     = aws_ecr_repository.main.repository_url
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
  name = "ai-typology"
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
  name            = "ai-typology"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  network_configuration {
    subnets          = [var.subnet1, var.subnet2]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.bg1.arn
    container_name   = "ai-typology"
    container_port   = 5000
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  lifecycle {
    ignore_changes = [task_definition, load_balancer]
  }
}