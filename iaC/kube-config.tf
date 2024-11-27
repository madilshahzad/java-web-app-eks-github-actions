resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.region} --name ${var.cluster_name} --role-arn ${var.assume_role_arn} --alias ${var.cluster_alias}"
  }
  depends_on = [
    module.eks,
    module.bastion_host,
    module.vpc

  ]
}