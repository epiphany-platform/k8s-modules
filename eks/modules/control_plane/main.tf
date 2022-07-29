terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.71.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "3.3.0"
    }
  }
}

# Create openid connect provider to be able to assign IAM Roles for Service Accounts
# https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
resource "aws_iam_openid_connect_provider" "eks_openid_connect_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  #https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
  thumbprint_list = [data.tls_certificate.eks_tls.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

data "tls_certificate" "eks_tls" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

data "aws_eks_cluster_auth" "eks_auth" {
  name       = aws_eks_cluster.eks_cluster.name
  depends_on = [aws_eks_cluster.eks_cluster]
}

# Enable control plane logging
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#enabling-control-plane-logging
resource "aws_cloudwatch_log_group" "eks_log_group" {
  name              = "${var.name}-log-group"
  retention_in_days = 30
  tags              = local.tags
}

resource "aws_eks_cluster" "eks_cluster" {
  name                      = var.name
  version                   = var.kubernetes_version
  role_arn                  = aws_iam_role.eks_cluster_iam_role.arn
  enabled_cluster_log_types = ["api", "audit"]
  tags                      = local.tags

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  # Ensure that IAM Role permissions and log group are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_iam_cluster_policy_attachment,
    aws_iam_role_policy_attachment.eks_iam_vpc_resource_controller_attachment,
    aws_cloudwatch_log_group.eks_log_group
  ]
}
