#############################
#    VPC Input Variables
#############################

# VPC Name
variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = "vpc"
}
# Region Name
variable "aws_region" {
  description = "Name of the AWS Region"
  type        = string
  default     = "us-east-1"
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

variable "common_tags" {}
variable "eks_cluster_name" {}
