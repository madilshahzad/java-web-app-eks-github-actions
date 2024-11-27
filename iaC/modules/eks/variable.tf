#############################
#    EKS Input Variables
#############################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}

variable "github_access_role_name" {
  description = "Role which can access the Cluster."
  type        = string
}
variable "cluster_service_ipv4_cidr" {
  description = "service ipv4 cidr for the kubernetes cluster"
  type        = string
  default     = null
}

variable "private_subnets" {
  description = "Target VPC subnet for cluster to be deployed"
  type        = list(string)
}

variable "cluster_version" {
  description = "Kubernetes minor version to use for the EKS cluster"
  type        = string
  default     = null
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "name_prefix" {
  description = "Common name prefix for resources"
}
variable "aws_ecr_repository" {
  description = "AWS ECR Repo for App Images"
  type = string
}
variable "repository_name" {
  description = "The name of the GitHub repository"
  type        = string
}
variable "cluster_admin_user_arn" {
  description = "ARN for the Admin principal to auth agianst eks"
  type        = string  
}

variable "ng_instance_type" {
  description = "EC2 Instance Type"
  type        = list(string)
}

variable "ng_ami_type" {
  description = "EC2 AMI Type"
  type        = string
  default     = "AL2_x86_64"
}

variable "ng_disk_size" {
  description = "Node group Disk Size"
  type        = string
  default     = "20"
}

variable "scaling_desired_size" {}
variable "scaling_max_size" {}
variable "scaling_min_size" {}
variable "common_tags" {}

variable "eks_oidc_root_ca_thumbprint" {
  type        = string
  description = "Thumbprint of Root CA for EKS OIDC"
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}