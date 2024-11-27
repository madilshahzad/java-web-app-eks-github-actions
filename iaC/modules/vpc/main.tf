data "aws_availability_zones" "available" {
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"
  name            = "${var.vpc_name}-${var.eks_cluster_name}"
  cidr            = var.vpc_cidr_block
  azs             = data.aws_availability_zones.available.names
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets
  database_subnets = var.vpc_protected_subnets
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags     = var.common_tags
  vpc_tags = var.common_tags
  public_subnet_tags = {
    Name = "VPC Public Subnets"
  }
  private_subnet_tags = {
    Name = "VPC Private Subnets"
  }
  database_subnet_tags = {
    Name = "VPC Private Database Subnets"
  }
  map_public_ip_on_launch = true
}