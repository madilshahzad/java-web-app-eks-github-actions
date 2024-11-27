#############################
# bastion_host Host Outputs
#############################

# bastion_host Host Instance ID
output "bastion_host_instance_id" {
  description = "The ID of the bastion_host host instance"
  value       = module.ec2_instance.id
}

# bastion_host Host Public IP
output "bastion_host_public_ip" {
  description = "The public IP address of the bastion_host host"
  value       = module.ec2_instance.public_ip
}

# bastion_host Host Security Group ID
output "bastion_host_security_group_id" {
  description = "The ID of the bastion_host host security group"
  value       = module.public_bastion_sg.security_group_id
}


