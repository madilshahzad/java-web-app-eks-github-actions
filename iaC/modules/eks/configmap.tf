data "template_file" "aws_auth" {
  template = file("${path.module}/template/aws-auth.tpl")

  vars = {
    node_role_arn  = var.node_role_arn
    master_role_arn = var.master_role_arn
    users = jsonencode(var.users)  
  }
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = yamldecode(data.template_file.aws_auth.rendered)["data"]
}
