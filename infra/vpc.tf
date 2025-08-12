module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"
  name    = var.vpc_name
  cidr    = var.vpc_cidr
  azs     = var.availability_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  enable_nat_gateway = true
  map_public_ip_on_launch = true
  # Ensure private subnets are associated with route tables that send 0.0.0.0/0 to NAT gateway
  # Check module.vpc.private_route_table_ids and association in AWS console if issues persist
}
