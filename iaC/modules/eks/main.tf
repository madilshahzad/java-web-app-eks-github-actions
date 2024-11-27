# Setting up IAM Policies 

resource "aws_iam_role" "eks_master_role"{
    name = "eks_master_role"
    assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "eks_master_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.eks_master_role.name
}

resource "aws_iam_role_policy_attachment" "eks_master_policy_controller" {

    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
    role = aws_iam_role.eks_master_role.name
  
}

# EKS Node Policies

resource "aws_iam_role" "eks_node_role" {
    name = "eks_node_role"
   assume_role_policy= jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
    
    })
}



resource "aws_iam_role_policy_attachment"  "eks-AmazonEKSWorkerNodePolicy"{
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment"  "eks-AmazonEKS_CNI_Policy"{
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment"  "eks-AmazonEC2ContainerRegistryReadOnly"{
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.eks_node_role.name
}

# Creating EKS Cluster

resource "aws_eks_cluster" "eks_cluster"{
    name = "eks_cluster"
    role_arn = aws_iam_role.eks_master_role.arn
    version = "1.26"
    vpc_config {
      subnet_ids=var.public_subnet_ids
      endpoint_private_access = var.cluster_endpoint_private_access
      endpoint_public_access = var.cluster_endpoint_public_access
      public_access_cidrs= var.cluster_endpoint_public_access_cidrs
    }


    kubernetes_network_config {
      service_ipv4_cidr = var.service_ipv4_cidr
    }
    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]


    depends_on = [

        aws_iam_role_policy_attachment.eks_master_policy,
        aws_iam_role_policy_attachment.eks_master_policy_controller
        
    ]
}

# Public Node 

resource "aws_eks_node_group" "eks_ng_public"{
    cluster_name = aws_eks_cluster.eks_cluster.name
    node_group_name = "eks_ng_public"
    node_role_arn = aws_iam_role.eks_node_role.arn
    subnet_ids = var.private_subnet_ids
    

    ami_type = "AL2_x86_64"
    capacity_type = "ON_DEMAND"
    disk_size = 20
    instance_types = ["t3.medium"]
    remote_access {
        ec2_ssh_key = "terraformmac"
    }
    scaling_config {
        desired_size = 1
        max_size = 2
        min_size = 1
    }
    update_config {
        max_unavailable = 1
    }
    depends_on = [
        aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly
    ]
    tags = {
        Name = "eks_ng_public"
    }
}

# Private Node

resource "aws_eks_node_group" "eks_ng_private"{
    cluster_name = aws_eks_cluster.eks_cluster.name
    node_group_name = "eks_ng_private"
    node_role_arn = aws_iam_role.eks_node_role.arn
    subnet_ids =  var.private_subnet_ids
    ami_type = "AL2_x86_64"
    capacity_type = "ON_DEMAND"
    disk_size = 20
    instance_types = ["t3.medium"]
    remote_access {
        ec2_ssh_key = "terraformmac"
    }
    scaling_config {
        desired_size = 1
        max_size = 2
        min_size = 1
    }
    update_config {
        max_unavailable = 1
    }
    depends_on = [
        aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly
    ]
    tags = {
        Name = "eks_ng_private"
    }
}

# OIDC Connect Provider 

data "aws_partition" "current" {}

resource "aws_iam_openid_connect_provider" "oidc_provider"{
    client_id_list = ["sts.${data.aws_partition.current.dns_suffix}"]
    thumbprint_list = [var.eks_oidc_root_ca_thumbprint]
    url = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
    tags = {
        Name = "oidc_Provider"
    }
}