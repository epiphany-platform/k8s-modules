locals {
  subnet_ids         = var.subnet_ids != null ? var.subnet_ids : aws_subnet.eks_subnet[*].id
  autoscaler_version = var.autoscaler_version != null ? var.autoscaler_version : local.autoscaler_default_versions[var.kubernetes_version]
  autoscaler_default_versions = {
    1.16 : "v1.16.7",
    1.17 : "v1.17.4",
    1.18 : "v1.18.3",
    1.19 : "v1.19.1",
    1.22 : "v1.22.2"
  }
}
