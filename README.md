# AWS EKS Terraform Project with GitHub Actions

## Overview
This project demonstrates a comprehensive setup for deploying and managing an AWS EKS (Elastic Kubernetes Service) cluster using Terraform, integrated with GitHub Actions for CI/CD workflows. The setup ensures secure, efficient, and scalable infrastructure provisioning and application deployment.

---

## Tools Used
- **Terraform**: Infrastructure as Code (IaC) tool for managing cloud resources.
- **GitHub Actions**: CI/CD workflows for automated provisioning, building, and deployment.
- **Helm**: Kubernetes package manager for deploying and managing applications.
- **Security Tools**:
  - **TfSec**: Terraform static analysis for security checks.
  - **Image Security**: Container image scanning for vulnerabilities.

---

## Terraform Modules Used
| Module                       | Purpose                                 |
|------------------------------|-----------------------------------------|
| **VPC**                     | Creates and manages the VPC, subnets, and routing tables. |
| **EKS Cluster**              | Provisions the EKS cluster and node groups. |
| **IAM Roles and Policies**   | Configures roles for service accounts using OIDC permissions. |
| **Security Groups**          | Manages access control for Kubernetes resources. |

---

## Sample `terraform.tfvars` File
```hcl

node_role_arn  = "arn:aws:iam::123456789012:role/sample_node_role"
master_role_arn = "arn:aws:iam::123456789012:role/sample_master_role"

users = [
    {
        user_arn = "arn:aws:iam::123456789012:role/sample-GitHub-Actions"
        username = "sample-GitHub-Actions"
        groups   = ["system:masters"]
    },
    {
        user_arn = "arn:aws:iam::123456789012:user/sample-user"
        username = "sample-user"
        groups   = ["system:masters"]
    },
    {
        user_arn = "arn:aws:iam::123456789012:user/sample-Terraform-Role"
        username = "sample-Terraform-Role"
        groups   = ["system:masters"]
    }
]
cluster_name = "sample-cluster"
cluster_version="1.26"
node_group_name = "sample-node-group"
key_name= "sample-key"
environment = "sample-env"
vpc_name = "sample-vpc"
bastion_name = "sample-bastion"
assume_role_arn = "arn:aws:iam::123456789012:role/sample-Terraform-Role"
kubeconfig_path = "~/.kube/config"
region = "us-east-1"
cluster_alias = "sample-cluster"
```

---

## How to Use
1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan with Variables**:
   ```bash
   terraform plan -var-file="terraform.tfvars"
   ```

3. **Apply Configuration**:
   ```bash
   terraform apply -var-file="terraform.tfvars"
   ```

---

## Requirements
- Terraform 1.3.0+
- AWS CLI 2.7+
- kubectl 1.25+
- Helm 3.9+
- GitHub Actions enabled with OIDC setup for AWS roles.

---

## Providers
| Provider   | Configuration Requirements |
|------------|-----------------------------|
| **AWS**    | Region, Access Credentials |
| **Kubernetes** | Kubernetes context from EKS |
| **Helm**   | Configured with EKS cluster context |

---

## GitHub Actions Workflows
| Workflow | Description |
|----------|-------------|
| [Main Workflow](https://github.com/madilshahzad/java-web-app-eks-github-actions) | Orchestrates child workflows and triggers pipelines. |
| [Infrastructure Provisioning](https://github.com/madilshahzad/infrastructure-provisioning) | Provisions EKS, VPC, and related resources. |
| [Build and Deploy](https://github.com/madilshahzad/Build-Deploy) | Builds application container images and deploys to Amazon ECR. |
| [Helm Charts Deployment](https://github.com/madilshahzad/helm_charts) | Deploys Helm charts to the Kubernetes cluster. |

---

## Security Integration
- **TfSec**:
  - Integrated in GitHub Actions for static analysis of Terraform code.
  - Automatically scans for vulnerabilities and misconfigurations before deployment.

- **Image Security**:
  - Scans Docker images for vulnerabilities before pushing to Amazon ECR.

---

## Access and Permissions
- **OIDC with AWS Roles**:
  - GitHub Actions uses AWS OIDC roles to access EKS securely without managing long-term credentials.

- **Developer Access**:
  - Developers can push to the feature branch.
  - Pull Requests (PRs) include:
    - Code validation.
    - Code security scans.
    - Manual review and approval.
  - Upon merge, the pipeline triggers the following:
    - Build and deployment to ECR.
    - Automatic Helm deployment to Kubernetes.

---

## Directory Structure
```plaintext
.
├── infrastructure-provisioning
│   └── Terraform modules
├── build-deploy
│   └── Dockerfiles and GitHub workflows
└── helm_charts
    └── Helm configuration and kubernetes deployment
```

---

## Permissions Level
| Role        | Permissions                              |
|-------------|------------------------------------------|
| **Developer** | Push to feature branch, submit PRs for review. |
| **Reviewer**  | Approve PRs after validation and scans. |
| **Pipeline**  | Execute workflows, deploy images to ECR, trigger Helm deployments. |



# Best practices and improvements

1. **Restrict Access to GitHub Repositories**:
  - Limit access to the GitHub repositories to enhance security. For assessment purposes, these repositories are currently public. 

2. **Implement Terraform State Management**:
  - Use remote state storage (e.g., AWS S3) with state locking (e.g., DynamoDB) to ensure consistency and prevent conflicts.

3. **Enable Multi-Factor Authentication (MFA)**:
  - Enforce MFA for accessing AWS resources to enhance security.

4. **Use IAM Policies with Least Privilege**:
  - Define and apply IAM policies that grant the minimum permissions required for each role.

5. **Regularly Update Dependencies**:
  - Keep Terraform, Helm, and other dependencies up to date to benefit from security patches and new features.

6. **Automate Security Scans**:
  - Integrate additional security tools (e.g., Checkov, Trivy) into the CI/CD pipeline for comprehensive security checks.

7. **Monitor and Log Activities**:
  - Implement logging and monitoring (e.g., AWS CloudWatch, Prometheus) to track and analyze activities within the EKS cluster.

8. **Backup and Disaster Recovery**:
  - Establish backup procedures and disaster recovery plans for critical components and data.

9. **Document Infrastructure and Processes**:
  - Maintain detailed documentation for infrastructure setup, CI/CD workflows, and operational procedures to facilitate onboarding and troubleshooting.