terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.78.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.34.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = var.aws_role_arn
    session_name = "TerraformSession"
  }
}



module "vpc" {
  source                = "./modules/vpc"
  vpc_name              = var.vpc_name
  aws_region            = var.aws_region
  vpc_cidr_block        = var.vpc_cidr_block
  vpc_public_subnets    = var.vpc_public_subnets
  vpc_private_subnets   = var.vpc_private_subnets
  vpc_protected_subnets = var.vpc_protected_subnets
  common_tags           = local.common_tags
  eks_cluster_name      = local.eks_cluster_name
}

module "bastion_host" {
  source           = "./modules/bastion"
  name_prefix      = local.name
  instance_type    = var.instance_type
  instance_keypair = var.instance_keypair
  common_tags      = local.common_tags
  vpc_id           = module.vpc.vpc_id
  vpc_subnets      = module.vpc.public_subnets[0]
  environment      = var.environment
}

module "eks" {
  source                          = "./modules/eks"
  name_prefix                     = local.name
  cluster_name                    = local.eks_cluster_name
  cluster_service_ipv4_cidr       = var.cluster_service_ipv4_cidr
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  private_subnets                 = module.vpc.private_subnets
  ng_instance_type                = var.ng_instance_type
  ng_ami_type                     = var.ng_ami_type
  ng_disk_size                    = var.ng_disk_size
  scaling_desired_size            = var.scaling_desired_size
  scaling_max_size                = var.scaling_max_size
  scaling_min_size                = var.scaling_min_size
  github_access_role_name         = var.github_access_role_name
  aws_ecr_repository              = var.aws_ecr_repository
  repository_name                 = var.repository_name
  cluster_admin_user_arn          = var.cluster_admin_user_arn
  aws_account_id                  = var.aws_account_id
  common_tags                     = local.common_tags
  aws_region                      = var.aws_region
}
