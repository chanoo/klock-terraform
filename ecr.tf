# ECR 생성
resource "aws_ecr_repository" "klock" {
  name = "${var.project_name}-repository"
}
