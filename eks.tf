locals {
  common_tags = {
    Terraform = "true"
  }
}

# EKS 클러스터 생성
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name = var.cluster_name
  subnets      = var.subnet_ids

  tags = local.common_tags
  vpc_tags = local.common_tags
  subnet_tags = local.common_tags

  vpc_id = var.vpc_id

  kubeconfig_aws_authenticator_env_variables = {
    AWS_PROFILE = var.aws_profile
  }

  kubeconfig_name = var.kubeconfig_name

  kubernetes_version = var.kubernetes_version

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 20
  }

  node_groups = {
    eks_nodes = {
      desired_capacity = var.desired_capacity
      max_capacity     = var.max_capacity
      min_capacity     = var.min_capacity

      instance_types = ["t2.small"]
      additional_security_group_ids = [aws_security_group.alb.id]
    }
  }

  manage_aws_auth = true

  write_kubeconfig      = true
  write_aws_auth_config = false
}

output "kubeconfig" {
  value = module.eks.kubeconfig
}

output "aws_auth" {
  value = module.eks.aws_auth_configmap_yaml
}
