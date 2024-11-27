variable "instance_type" {
  default = "t2.large"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC Cidr Block"

}

variable "vpc_public_subnet_cidr_block" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "vpc_private_subnet_cidr_block" {

  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]

}

variable "vpc_database_subnet" {
  type        = list(string)
  default     = ["10.0.151.0/24", "10.0.152.0/24"]
  description = "description"
}

variable "vpc_availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "cluster_endpoint_private_access" {

  description = "cluster endpoint private access"
  type        = bool
  default     = true

}

variable "cluster_endpoint_public_access" {

  description = "cluster endpoint public access"
  type        = bool
  default     = true


}

variable "cluster_endpoint_public_access_cidrs" {

  description = "cluster endpoint public access cidrs"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "service_ipv4_cidr" {
  description = "The CIDR block to allow public access to the cluster"
  type        = string
  default     = null
}
variable "eks_oidc_root_ca_thumbprint" {
  description = "The root certificate of the issuer used to issue OIDC tokens for Kubernetes Service Accounts."
  type        = string
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}


variable "node_role_arn" {
  description = "ARN of the EKS node role"
  type        = string
}

variable "master_role_arn" {
  description = "ARN of the EKS master role"
  type        = string
}

variable "users" {
  description = "List of users with their roles and groups"
  type = list(object({
    user_arn = string
    username = string
    groups   = list(string)
  }))
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
}

variable "key_name" {
  description = "Name of the key pair"
  type        = string
}