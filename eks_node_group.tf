# eks_node_group.tf

resource "aws_security_group" "node_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  description = "EKS worker group management one"
  vpc_id      = aws_vpc.this.id
}

resource "aws_security_group" "node_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  description = "EKS worker group management two"
  vpc_id      = aws_vpc.this.id
}

resource "aws_security_group_rule" "worker_group_mgmt_one" {
  security_group_id = aws_security_group.node_group_mgmt_one.id

  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/8"]
}

resource "aws_security_group_rule" "worker_group_mgmt_two" {
  security_group_id = aws_security_group.node_group_mgmt_two.id

  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/8"]
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "aws-load-balancer-controller-coredns"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = [aws_subnet.this["private-a"].id, aws_subnet.this["private-b"].id]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.micro"]

  remote_access {
    ec2_ssh_key               = aws_key_pair.deployer.key_name
    source_security_group_ids = [aws_security_group.node_group_mgmt_one.id, aws_security_group.node_group_mgmt_two.id]
  }

  depends_on = [
    aws_security_group_rule.worker_group_mgmt_one,
    aws_security_group_rule.worker_group_mgmt_two,
  ]
}

resource "aws_iam_policy" "eks_node_group_elb_permissions" {
  name        = "eks-node-group-elb-permissions"
  description = "EKS Node Group ELB permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_group_elb_permissions" {
  policy_arn = aws_iam_policy.eks_node_group_elb_permissions.arn
  role       = aws_iam_role.eks_node_group.name // 수정된 부분
}
