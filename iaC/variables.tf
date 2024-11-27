# Project Name
variable "project" {
  description = "Name of the Project"
  type        = string
}
# AWS Region
variable "aws_region" {
  description = "Name of the AWS Region"
  type        = string
}
# Environment Name
variable "environment" {
  description = "Name of the AWS Environment"
  type        = string
}
# AWS Account ID
variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

# Local Values in Terraform
locals {
  owners      = var.project
  environment = var.environment
  name        = "${var.project}-${var.environment}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
  eks_cluster_name = "${local.name}-${var.cluster_name}"
}

#############################
#    VPC Input Variables
#############################
# VPC Name
variable "vpc_name" {
  description = "VPC Name"
  type        = string
}
# VPC CIDR Block
variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type        = string
}
# VPC Public Subnets
variable "vpc_public_subnets" {
  description = "VPC Public Subnets"
  type        = list(string)
}
# VPC Private Subnets
variable "vpc_private_subnets" {
  description = "VPC Private Subnets"
  type        = list(string)
}
# VPC Database Subnets
variable "vpc_protected_subnets" {
  description = "VPC Database Subnets"
  type        = list(string)
}

#############################
#    Bastion Host Input Variables
#############################

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
}

variable "instance_keypair" {
  description = "AWS EC2 Key pair that needs to be associated with EC2 Instance"
  type        = string
}

#############################
#    EKS Cluster Input Variables
#############################


# EKS Cluster Input Variables
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
variable "github_access_role_name" {
  description = "Role which can access the cluster"
  type        = string
}
variable "cluster_service_ipv4_cidr" {
  description = "service ipv4 cidr for the kubernetes cluster"
  type        = string
}
variable "cluster_version" {
  description = "Kubernetes minor version to use for the EKS cluster"
  type        = string
}
variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
}
variable "aws_ecr_repository" {
  description = "AWS ECR Repo for Web App Images"
  type        = string
}
variable "repository_name" {
  description = "The name of the GitHub repository"
  type        = string
}
variable "cluster_admin_user_arn" {
  description = "ARN for the principal to authenticate agianst eks"
  type        = string
}

variable "ng_instance_type" {
  description = "EC2 Instance Type"
  type        = list(string)
}

variable "ng_ami_type" {
  description = "EC2 AMI Type"
  type        = string
}

variable "ng_disk_size" {
  description = "Node group Disk Size"
  type        = string
}
variable "scaling_desired_size" {}
variable "scaling_max_size" {}
variable "scaling_min_size" {}

variable "aws_role_arn" {
  description = "ARN of the role to assume"
  type        = string
}

