# ECR
resource "aws_ecr_repository" "main" {
  name = "ai-typology"
  force_delete = true
}

# docker build & push
resource "null_resource" "default" {
  triggers = {
    file_content_sha1 = sha1(join("", [for f in ["build-docker.sh", "../Dockerfile", "../front/Dockerfile"]: filesha1(f)]))
  }

  provisioner "local-exec" {
    command = "sh ./build-docker.sh"
  }
}