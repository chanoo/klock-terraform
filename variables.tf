variable "project_name" {
  description = "프로젝트 이름"
  default     = "klock"
}

variable "domain_name" {
  description = "애플리케이션의 기본 도메인 이름"
  default     = "klock.app"
}

variable "subdomain_names" {
  description = "애플리케이션의 하위 도메인 목록"
  default     = ["www", "api"]
}

variable "target_domains" {
  description = "하위 도메인별 로드 밸런서 또는 기타 리소스의 대상 도메인"
  default     = {
    "www"  = "your-www-load-balancer-domain.amazonaws.com"
    "api"  = aws_lb.alb.dns_name
  }
}

variable "target_zone_ids" {
  description = "하위 도메인별 대상 도메인의 영역 ID"
  default     = {
    "www"  = "ZONE_ID_OF_WWW_TARGET"
    "api"  = aws_lb.alb.zone_id
  }
}

variable "s3_bucket_name" {
  description = "S3 버킷의 고유한 이름"
  default     = "klock-bucket"
}

variable "cluster_name" {
  description = "EKS 클러스터의 이름"
  default     = "klock-eks"
}

variable "subnet_ids" {
  description = "EKS 클러스터에 사용될 서브넷 ID 목록"
  type        = list(string)
}

variable "aws_profile" {
  description = "인증에 사용할 AWS 프로필"
  default     = "default"
}

variable "kubeconfig_name" {
  description = "생성된 kubeconfig 파일의 이름"
  default     = "klock-eks-config"
}

variable "kubernetes_version" {
  description = "EKS 클러스터에서 원하는 쿠버네티스 버전"
  default     = "1.21"
}

variable "desired_capacity" {
  description = "워커 노드의 원하는 개수"
  default     = 2
}

variable "max_capacity" {
  description = "워커 노드의 최대 개수"
  default     = 5
}

variable "min_capacity" {
  description = "워커 노드의 최소 개수"
  default     = 1
}

variable "vpc_id" {
  description = "EKS 클러스터가 배포될 VPC ID"
}
