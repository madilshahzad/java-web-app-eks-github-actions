data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  } 
}


# Security Group Moudule 
 
module "bastion_host_security_group"{

  source = "terraform-aws-modules/security-group/aws"
  version = "4.5.0"
  name = "bastion_host_security_group"
  description = "Security group for bastion host"
  vpc_id = var.vpc_id
  ingress_rules=["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]
}

# EIP Module 

resource "aws_eip" "bastion_host_eip"{
  vpc = true
  instance = module.ec2_public.id
  depends_on = [module.ec2_public]
  tags = {
    Name = "bastion_host_eip"
  }
}


module "ec2_public"{
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "3.3.0"
  name = "bastion_host"
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




