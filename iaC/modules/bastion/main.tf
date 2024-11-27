data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_iam_role" "bastion_host_ssm_role" {
  name               = "bastion-host-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ssm_assume_role.json
}

data "aws_iam_policy_document" "ssm_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}


# Elastic IP
resource "aws_eip" "bastion_eip" {
  instance = module.ec2_instance.id
  domain   = "vpc"
  tags     = var.common_tags
}

#############################
#    EC2 Security Group
#############################

module "public_bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${var.environment}-public-bastion-sg"
  description = "Security Group with SSH port open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id      = var.vpc_id

  # Ingress Rules & CIDR Blocks
  ingress_rules       = var.bastion_ingress_port_rule
  ingress_cidr_blocks = var.bastion_ingress_CIDR

  # Egress Rule - all-all open
  egress_rules = ["all-all"]
  tags         = var.common_tags
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0"
  name          = "${var.name_prefix}-BastionHost"
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.instance_keypair
  subnet_id              = var.vpc_subnets
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]
  tags                   = var.common_tags
}
