# AWS IAM Role and Policies
# OIDC Permissions for GitHub
# Data Source for Load Balancer Controller IAM Policy

data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
}

output "lbc_iam_policy" {
  value = data.http.lbc_iam_policy.response_body
}

provider "aws" {
  region = var.aws_region
}
# AWS Caller Identity Data Source
data "aws_caller_identity" "current" {}
# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions_role" {
  name = var.github_access_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.repository_name}"
          },
          StringEqualsIgnoreCase = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = var.cluster_admin_user_arn
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name   = "GitHubActionsPolicy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Sid    = "ECRPermissions",
          Effect = "Allow",
          Action = [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage",
            "ecr:GetAuthorizationToken"
          ],
          Resource = "*"
        },
        {
          Sid    = "DescribeCluster",
          Effect = "Allow",
          Action = "eks:DescribeCluster",
          Resource = "arn:aws:eks:${var.aws_region}:${var.aws_account_id}:cluster/${var.cluster_name}"
        }
      ]
    })
  }
}

# OIDC Provider
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.eks_oidc_root_ca_thumbprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

# IAM Role for EKS Master
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

resource "aws_iam_role_policy_attachment" "eks_master_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master_role.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_master_role.name
}

# IAM Role for Node Group
resource "aws_iam_role" "eks_nodegroup_role" {
  name = "${var.name_prefix}-eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks_registry_readonly_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role.name
}

# Kubernetes ConfigMap for aws-auth
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<YAML
- rolearn: ${aws_iam_role.eks_nodegroup_role.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: ${aws_iam_role.eks_master_role.arn}
  username: eks-master-role
  groups:
    - system:masters
YAML
  }
}

# EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_master_role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_subnets
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

# EKS Node Group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = var.private_subnets

  scaling_config {
    desired_size = var.scaling_desired_size
    min_size     = var.scaling_min_size
    max_size     = var.scaling_max_size
  }

  instance_types = var.ng_instance_type
  disk_size      = var.ng_disk_size
}
