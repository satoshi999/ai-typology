# SECURITY GROUP
resource "aws_security_group" "alb" {
  name        = "ai-typology-alb"
  description = "ai-typology-alb"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
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
    Name = "ai-typology-alb"
  }
}

# ALB
resource "aws_lb" "main" {
  name               = "ai-typology"
  internal           = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb.id]

  subnets = [var.subnet1, var.subnet2]

  ip_address_type = "ipv4"

  tags = {
    Name = "ai-typology"
  }
}

# TARGET GROUP
resource "aws_lb_target_group" "bg1" {
  name             = "ai-typology-bg1"
  target_type      = "ip"
  protocol_version = "HTTP1"
  port             = 80
  protocol         = "HTTP"

  vpc_id = var.vpc_id

  tags = {
    Name = "ai-typology"
  }

  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200,301"
  }
}

resource "aws_lb_target_group" "bg2" {
  name             = "ai-typology-bg2"
  target_type      = "ip"
  protocol_version = "HTTP1"
  port             = 80
  protocol         = "HTTP"

  vpc_id = var.vpc_id

  tags = {
    Name = "ai-typology"
  }

  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200,301"
  }
}

# LISTENER
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bg1.arn
  }
}