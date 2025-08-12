module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"
  name    = var.vpc_name
  cidr    = var.vpc_cidr
  azs     = var.availability_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  # Disable NAT gateways to avoid allocating Elastic IPs
  enable_nat_gateway = true
  # Ensure instances launched in public subnets get a public IPv4
  map_public_ip_on_launch = true
}
