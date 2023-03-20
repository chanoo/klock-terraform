# aws_lb_controller.tf

resource "aws_iam_role" "aws_load_balancer_controller" {
  name = "aws-load-balancer-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "elasticloadbalancing.amazonaws.com",
            "eks.amazonaws.com",
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

locals {
  policy_arns = {
    AmazonEKSClusterPolicy         = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    AmazonEKSVPCResourceController = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
    AWSLoadBalancerController      = aws_iam_policy.aws_load_balancer_controller.arn
  }
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_policies" {
  for_each   = local.policy_arns
  policy_arn = each.value
  role       = aws_iam_role.aws_load_balancer_controller.name
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "aws-load-balancer-controller"
  description = "Policy for AWS Load Balancer Controller"

  policy = file("iam-policy.json")
}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.4.8"
  namespace  = "kube-system"
  timeout    = 600

  values = [
    yamlencode({
      clusterName              = aws_eks_cluster.this.name
      serviceAccount           = {
        create = false
        name   = kubernetes_service_account.aws_load_balancer_controller.metadata[0].name
      }
      vpcId                    = aws_vpc.this.id
      region                   = "ap-northeast-2"
    })
  ]
}
