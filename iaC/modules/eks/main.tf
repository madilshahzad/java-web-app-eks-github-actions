# AWS IAM Role and Policies 
# OIDC PErmissions for GitHub 
# Data Source for Load Balancer Controller IAM Policy

data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

output "lbc_iam_policy" {
  value = data.http.lbc_iam_policy.response_body
}

provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "github_actions_role" {
  name = var.github_access_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.repository_name}"
          }
          StringEqualsIgnoreCase = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
            AWS = var.cluster_admin_user_arn 
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name   = "OidcSafetyPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "OidcSafeties"
          Effect = "Deny"
          Action = "sts:AssumeRole"
          Resource = "*"
        }
      ]
    })
  }

  inline_policy {
    name   = "GitHubActionsECRPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "AllowPushPull"
          Effect = "Allow"
          Action = [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:GetAuthorizationToken"
          ]
          Resource = "*"
        },
        {
          Sid    = "AllowEKSClusterAccess"
          Effect = "Allow"
          Action = "eks:DescribeCluster"
          Resource = "arn:aws:eks:${var.aws_region}:${var.aws_account_id}:cluster/${var.cluster_name}"
        }
      ]
    })
  }
}

data "aws_caller_identity" "current" {}

# OIDC Connector for EKS


data "aws_partition" "current" {}

# AWS IAM Open ID Connect Provider
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.${data.aws_partition.current.dns_suffix}"]
  thumbprint_list = [var.eks_oidc_root_ca_thumbprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

  tags = merge(
    {
      Name = "${var.cluster_name}-eks-irsa"
    },
    var.common_tags
  )
}

# AWS IAM Open ID Connect Provider ARN
output "aws_iam_openid_connect_provider_arn" {
  description = "AWS IAM Open ID Connect Provider ARN"
  value = aws_iam_openid_connect_provider.oidc_provider.arn 
}

# Extract OIDC Provider from OIDC Provider ARN
locals {
    aws_iam_oidc_connect_provider_extract_from_arn = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.oidc_provider.arn}"), 1)
}

# AWS IAM Open ID Connect Provider
output "aws_iam_openid_connect_provider_extract_from_arn" {
  description = "AWS IAM Open ID Connect Provider extract from ARN"
   value = local.aws_iam_oidc_connect_provider_extract_from_arn
}

# IAM Roles

# IAM Role for EKS
resource "aws_iam_role" "eks_master_role" {
  name = "${var.name_prefix}-eks-master-role"

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

# Associate IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_master_role.name
}

# IAM Role for EKS Node Group

# EKS Node Group IAM Role 
resource "aws_iam_role" "eks_nodegroup_role" {
  name = "${var.name_prefix}-eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role.name
}
resource "aws_iam_role_policy_attachment" "eks-AmazonEC2RoleforSSM" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.eks_nodegroup_role.name
}
resource "aws_iam_role_policy_attachment" "eks-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_nodegroup_role.name
}


# Access Entry
resource "aws_eks_access_entry" "github_eks_cluster" {
  depends_on        = [aws_eks_cluster.eks_cluster, aws_iam_role.github_actions_role]
  cluster_name      = aws_eks_cluster.eks_cluster.name
  principal_arn     = aws_iam_role.github_actions_role.arn
  type              = "STANDARD"
}

# Access Entry Policy Association
resource "aws_eks_access_policy_association" "github_eks_cluster" {
  depends_on    = [aws_eks_cluster.eks_cluster, aws_iam_role.github_actions_role]
  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.github_actions_role.arn

  access_scope {
    type       = "cluster"
  }
}

resource "aws_eks_access_entry" "admin_user_eks_cluster" {
  cluster_name      = aws_eks_cluster.eks_cluster.name
  principal_arn     = var.cluster_admin_user_arn
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_user_eks_cluster" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.cluster_admin_user_arn

  access_scope {
    type       = "cluster"
  }
}

# Loadbalancer Controller IAM Policy


# AWS Load Balancer Controller IAM Policy 
resource "aws_iam_policy" "lbc_iam_policy" {
  name        = "${var.cluster_name}-AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "AWS Load Balancer Controller IAM Policy"
  policy = data.http.lbc_iam_policy.response_body
}

output "lbc_iam_policy_arn" {
  value = aws_iam_policy.lbc_iam_policy.arn 
}

# IAM Role 
resource "aws_iam_role" "lbc_iam_role" {
  name = "${var.cluster_name}-lbc-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.oidc_provider.arn}"
        }
        Condition = {
          StringEquals = {
            "${local.aws_iam_oidc_connect_provider_extract_from_arn}:aud": "sts.amazonaws.com",            
            "${local.aws_iam_oidc_connect_provider_extract_from_arn}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }        
      },
    ]
  })

  tags = {
    tag-key = "AWSLoadBalancerControllerIAMPolicy"
  }
}

resource "aws_iam_role_policy_attachment" "lbc_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.lbc_iam_policy.arn 
  role       = aws_iam_role.lbc_iam_role.name
}

output "lbc_iam_role_arn" {
  description = "AWS Load Balancer Controller IAM Role ARN"
  value = aws_iam_role.lbc_iam_role.arn
}

# AWS EKS Nodes

# AWS EKS Node Group
resource "aws_eks_node_group" "eks_ng_private" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-ng-private"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = var.private_subnets
  version         = var.cluster_version

  ami_type       = var.ng_ami_type
  capacity_type  = "ON_DEMAND"
  disk_size      = var.ng_disk_size
  instance_types = var.ng_instance_type

  scaling_config {
    desired_size = var.scaling_desired_size
    min_size     = var.scaling_min_size
    max_size     = var.scaling_max_size
  }
  
  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ]
  tags = {
    Name = "Private-Node-Group"
  }
}

# AWS EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_master_role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_subnets
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
  }
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

  # Enable EKS Cluster Control Plane Logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]
}

# AWS ECR Repo
resource "aws_ecr_repository" "ecr_repo" {
  name                 = var.aws_ecr_repository 
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}