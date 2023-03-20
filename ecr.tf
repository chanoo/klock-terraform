# ecr.tf

resource "aws_ecr_repository" "klock_repository" {
  name = "klock-repository"
}
