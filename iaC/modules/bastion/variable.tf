#############################
#    EC2 Input Variables
#############################

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t2.micro"
}
variable "instance_keypair" {
  description = "AWS EC2 Key pair that need to be associated with EC2 Instance"
  type        = string
}
variable "bastion_ingress_port_rule" {
  description = "Ingress Rule List"
  type        = list(string)
  default     = ["ssh-tcp"]
}
variable "bastion_ingress_CIDR" {
  description = "Ingress Rule List"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
variable "name_prefix" {
  description = "Name of Common Name for Resources"
}
variable "common_tags" {
  description = "Common Tags for Resources"
}
variable "vpc_id" {
  description = "VPC ID to deploy"
}
variable "vpc_subnets" {
  description = "VPC Subnet in which ec2 will be deployed"
}
variable "environment" {
  description = "Environment Name"
}