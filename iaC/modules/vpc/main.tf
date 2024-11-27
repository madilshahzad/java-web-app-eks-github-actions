data "aws_availability_zones" "available" {}

module "vpc"{
    source = "github.com/terraform-aws-modules/terraform-aws-vpc"
    name = var.vpc_name
    cidr = var.vpc_cidr_block
    azs = var.vpc_availability_zones
    public_subnets = var.vpc_public_subnet_cidr_block
    private_subnets = var.vpc_private_subnet_cidr_block
    database_subnets = var.vpc_database_subnet
    create_database_subnet_route_table = true
    map_public_ip_on_launch = true

    enable_nat_gateway = true
    single_nat_gateway = true

    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Terraform = "true"
        Environment = var.environment
    }

    
}