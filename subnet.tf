# Subnet 생성
resource "aws_subnet" "private" {
  count = 2

  cidr_block = "10.0.${count.index + 1}.0/24"
  vpc_id     = aws_vpc.klock.id

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
  }
}
