resource "aws_security_group" "eks_cluster" {
  name        = "eks-cluster-sg"
  description = "EKS Cluster security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow Kubernetes API from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "Allow Kubernetes API from public internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}

resource "aws_security_group" "eks_node_group" {
  name        = "eks-node-group-sg"
  description = "EKS Node Group security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow all traffic from cluster SG"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-node-group-sg"
  }
}
