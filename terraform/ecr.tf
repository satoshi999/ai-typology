# ECR
resource "aws_ecr_repository" "main" {
  name = "ai-typology"
  force_delete = true
}