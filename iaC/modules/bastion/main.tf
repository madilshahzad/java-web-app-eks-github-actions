module "ec2_public"{
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "3.3.0"
  name = var.bastion_name
  ami = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  associate_public_ip_address = true
  key_name = var.key_name
  subnet_id = var.public_subnets[0]
  vpc_security_group_ids = [module.bastion_host_security_group.security_group_id]

  tags = {
    Name = "bastion_host"
  }
}




