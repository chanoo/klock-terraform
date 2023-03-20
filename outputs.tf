output "aws_ecr_repository_url" {
  value = aws_ecr_repository.klock.repository_url
}

output "aws_eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
