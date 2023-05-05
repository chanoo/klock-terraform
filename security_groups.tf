# security_groups.tf

resource "aws_security_group" "worker_mgmt" {
  name_prefix = "worker_mgmt"
  description = "Allow Kubernetes API server access from a specific security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  ingress {
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }
}

resource "aws_security_group_rule" "worker_mgmt_control_plane" {
  security_group_id = aws_security_group.worker_mgmt.id

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  source_security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id

  depends_on = [aws_eks_cluster.this]
}

output "worker_mgmt_sg_id" {
  value = aws_security_group.worker_mgmt.id
}
