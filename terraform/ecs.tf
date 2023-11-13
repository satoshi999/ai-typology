variable ecs_task_execution_role {}
variable vpc_id {}
variable subnet {}

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

# SECURITY GROUP
resource "aws_security_group" "main" {
  name        = var.project
  description = var.project
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 5000
    to_port          = 5000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.project
  }
}

# SERVICE
resource "aws_ecs_service" "main" {
  name            = var.project
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  network_configuration {
    subnets          = [var.subnet]
    security_groups  = [aws_security_group.main.id]
    assign_public_ip = true
  }
}