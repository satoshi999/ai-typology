resource "aws_security_group" "vpc_endpoint" {
  name   = "vpc_endpoint_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  service_name      = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type = "Interface"
  vpc_id            = var.vpc_id
  subnet_ids        = [var.subnet]

  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  private_dns_enabled = true

  tags = {
    "Name" = "ecr-api"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  service_name      = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  vpc_id            = var.vpc_id
  subnet_ids        = [var.subnet]

  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]

  private_dns_enabled = true

  tags = {
    "Name" = "ecr-dkr"
  }
}