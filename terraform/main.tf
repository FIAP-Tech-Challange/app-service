# Terraform para Tech Challenge

terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider AWS
provider "aws" {
  region = var.aws_region
}

# Provider Kubernetes
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Data sources para EKS
data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

# Data source para RDS (SSM Parameters)
# Usando os mesmos paths do CI para consistência
data "aws_ssm_parameter" "rds_host" {
  name = "/main/rds_endpoint"
}

data "aws_ssm_parameter" "rds_user" {
  name = "main/db_username"
}

data "aws_ssm_parameter" "rds_password" {
  name = "main/db_password"
}
