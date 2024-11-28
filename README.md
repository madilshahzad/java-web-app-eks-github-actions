# AWS EKS Terraform GitHub Actions Project

## Overview
This repository showcases a streamlined workflow for managing an Amazon Elastic Kubernetes Service (EKS) infrastructure using Terraform, GitHub Actions, and integrated security tools. The goal is to ensure efficient, secure, and automated deployment of containerized applications.

---

## Tools and Technologies

| **Category**         | **Tools/Services**                                                             |
|----------------------|---------------------------------------------------------------------------------|
| **Infrastructure as Code** | Terraform                                                                 |
| **Version Control**   | GitHub                                                                       |
| **CI/CD Pipeline**    | GitHub Actions                                                               |
| **Container Management** | Docker, Amazon ECR                                                          |
| **Kubernetes Management** | Amazon EKS, Helm Charts                                                     |
| **Security**          | TFSec (Terraform security), Trivvy for Image Security Scanner                           |
| **IAM Management**    | AWS IAM roles with OIDC permissions                                           |

---

## Terraform Modules

The project uses modular Terraform configurations for better scalability and reusability. Below is an overview of the key modules:

| **Module**                | **Description**                                                                 |
|---------------------------|---------------------------------------------------------------------------------|
| `eks-cluster`             | Provisions the Amazon EKS cluster and associated resources                     |
| `node-groups`             | Configures and manages worker node groups for the EKS cluster                  |
| `vpc`                     | Creates the Virtual Private Cloud (VPC), subnets, and networking components     |
| `iam`                     | Manages IAM roles and policies for EKS and GitHub Actions                      |
| `security-groups`         | Configures security groups and ingress/egress rules for cluster communication  |

---

## GitHub Actions Workflows

### Main Workflow
The `main` workflow acts as a trigger for child workflows, ensuring modular and efficient execution.

| **Workflow**                | **Description**                                                                                     | **Link**                                                                 |
|-----------------------------|-----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------|
| **Main**                    | Triggers child workflows for infrastructure provisioning, image build, and Helm deployments.        | [View Workflow](https://github.com/madilshahzad/java-web-app-eks-github-actions) |
| **Infrastructure Provisioning** | Deploys and manages infrastructure using Terraform.                                               | [View Workflow](https://github.com/madilshahzad/infrastructure-provisioning) |
| **Build and Deploy to ECR** | Builds the Docker image and pushes it to Amazon ECR.                                               | [View Workflow](https://github.com/madilshahzad/Build-Deploy) |
| **Helm Charts Deployment**  | Deploys application Helm charts to the Kubernetes cluster.                                          | [View Workflow](https://github.com/madilshahzad/helm_charts) |

---

## Security Measures

| **Category**        | **Tool/Implementation**                                                      |
|---------------------|-----------------------------------------------------------------------------|
| **Terraform Security** | TFSec scans Terraform code for security issues.                           |
| **Image Security**  | Ensures container images are scanned for vulnerabilities before deployment. |
| **IAM Permissions** | Implements AWS IAM roles with OIDC for GitHub Actions workflows to access EKS. |

---

## Workflow Permissions

| **Role**           | **Permissions**                                                                                   |
|--------------------|-------------------------------------------------------------------------------------------------|
| **Developer**      | Can push to feature branches. Pull Requests (PRs) trigger code review and security checks.       |
| **Reviewer**       | Reviews code and approves PRs. Approved PRs trigger pipelines for build and deployment.          |

---

## CI/CD Workflow Overview

1. **Feature Development**
    - Developers push code to feature branches.
    - GitHub Actions runs code quality and security checks on PR creation.

2. **Code Review and Merge**
    - Approved PRs are merged into the `main` branch.

3. **Pipeline Trigger**
    - Terraform-based infrastructure provisioning workflow is triggered.
    - Docker images are built and pushed to ECR.

4. **Application Deployment**
    - Helm charts are deployed to the EKS cluster to update the Kubernetes environment.

---

## Access and OIDC Permissions

GitHub Actions uses AWS IAM roles with OIDC permissions to securely access the EKS cluster and deploy resources. Ensure the following:

- **OIDC Provider**: Configured for the GitHub repository.
- **IAM Role Policies**:
  - EKS cluster management.
  - Read/write access to ECR.
  - Kubernetes deployment permissions.

---





