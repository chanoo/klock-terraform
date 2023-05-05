# eks.tf

locals {
  cluster_name = "klock-eks-cluster"
  oidc_issuer_host = "https://oidc.eks.ap-northeast-2.amazonaws.com/id/91BE807A0EC9EE1737CBD52685DA8FF7"
}

resource "kubernetes_namespace" "klock_namespace" {
  metadata {
    name = "klock"
  }
}

provider "kubernetes" {
  host                   = aws_eks_cluster.this.endpoint
  token                  = data.aws_eks_cluster_auth.this.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority.0.data)
  config_path = "~/.kube/config"
}

data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.this.name
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name
}

resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  enabled_cluster_log_types = []

  vpc_config {
    subnet_ids = values(aws_subnet.this)[*].id
  }

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list = ["sts.amazonaws.com"]
  url = local.oidc_issuer_host
  thumbprint_list = [ 
    data.tls_certificate.this.certificates.0.sha1_fingerprint
  ]
}

data "tls_certificate" "this" {
  url = data.aws_eks_cluster.this.identity.0.oidc.0.issuer
}

resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_eks_fargate_profile" "klock_eks_fargate_profile" {
  cluster_name = aws_eks_cluster.this.name
  fargate_profile_name = "klock-fargate-profile"

  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn

  selector {
    namespace = kubernetes_namespace.klock_namespace.metadata.0.name
  }

  selector {
    namespace = "default"
  }

  subnet_ids = [
    aws_subnet.this["private-a"].id,
    aws_subnet.this["private-b"].id,
  ]
}

resource "aws_iam_role" "fargate_pod_execution_role" {
  name = "fargate-pod-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")

  lifecycle {
    ignore_changes = [key_name, public_key]
  }
}

resource "aws_iam_role" "eks_node_group" {
  name = "eks-node-group"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fargate_pod_execution_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_pod_execution_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
} 

resource "aws_iam_role_policy_attachment" "klock_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "klock_ecr_read_only_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_admin_access" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.eks_node_group.name
}
