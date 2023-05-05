# vpc.tf

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "VPC ${local.cluster_name}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "this" {
  for_each = {
    "public-a"  = "10.0.1.0/24"
    "public-b"  = "10.0.2.0/24"
    "private-a" = "10.0.3.0/24"
    "private-b" = "10.0.4.0/24"
  }

  cidr_block = each.value
  vpc_id      = aws_vpc.this.id
  map_public_ip_on_launch = contains(["public-a", "public-b"], each.key)

  tags = merge(
    {
      Name = each.key
      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    },
    contains(["public-a", "public-b"], each.key) ? {
      "kubernetes.io/role/elb" = "1"
    } : {
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "eip-nat-1"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.this["public-a"].id

  tags = {
    Name = "nat-a"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.this["private-a"].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.this["private-b"].id
  route_table_id = aws_route_table.private.id
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "klock-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.this["public-a"].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.this["public-b"].id
  route_table_id = aws_route_table.public.id
}

resource "aws_iam_policy" "amazon_vpc_cni_policy" {
  name        = "AmazonVPCCNIPolicy"
  description = "Policy for Amazon VPC CNI plugin"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action = "*"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amazon_vpc_cni_attachment" {
  policy_arn = aws_iam_policy.amazon_vpc_cni_policy.arn
  role       = aws_iam_role.eks_node_group.name
}
