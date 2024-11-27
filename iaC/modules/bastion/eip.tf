resource "aws_eip" "bastion_host_eip"{
  instance = module.ec2_public.id
  depends_on = [module.ec2_public]
  tags = {
    Name = "bastion_host_eip"
  }
}