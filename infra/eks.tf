module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.0.6"
  name    = var.cluster_name
  # Place nodes in public subnets to avoid NAT/EIP usage
  # Use private subnets for worker nodes (no public IPs)
  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  eks_managed_node_groups = {
    default = {
      desired_size   = var.node_desired_capacity
      max_size       = var.node_max_capacity
      min_size       = var.node_min_capacity
      instance_types = var.node_instance_types
      kubernetes_version = var.kubernetes_version
      iam_role_arn = aws_iam_role.node_group.arn
    }
  }

  enable_irsa = true
}
