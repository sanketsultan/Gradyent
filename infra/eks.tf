module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.13.0"
  name    = var.cluster_name
  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  # Security groups are set in eks_managed_node_groups only

  eks_managed_node_groups = {
    default = {
      desired_size   = var.node_desired_capacity
      max_size       = var.node_max_capacity
      min_size       = var.node_min_capacity
      instance_types = var.node_instance_types
      kubernetes_version = var.kubernetes_version
      iam_role_arn = aws_iam_role.node_group.arn
      security_group_ids = [aws_security_group.eks_node_group.id]
    }
  }

  enable_irsa = true

  compute_config = {
    enabled = true
  }

  addons = {
    kube-proxy = {
      lifecycle = {
        create_before_destroy = true
        ignore_changes = []
      }
    }
    coredns = {
      lifecycle = {
        create_before_destroy = true
        ignore_changes = []
      }
    }
  }

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = false
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
}
