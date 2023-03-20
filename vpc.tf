# VPC 생성
resource "aws_vpc" "klock" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.project_name}-vpc"
  }
}
