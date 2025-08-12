output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "eks_cluster_security_group_id" {
  value = aws_security_group.eks_cluster.id
}

output "eks_node_group_security_group_id" {
  value = aws_security_group.eks_node_group.id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}
