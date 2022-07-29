locals {
  tags = {
    "resource_group" = var.name
  }

  eks_node_tags = merge(
    local.tags, {
      "k8s.io/cluster-autoscaler/enabled" = "true",
      "k8s.io/cluster-autoscaler/${var.name}" = "owned",
      "kubernetes.io/cluster/${var.name}" = "owned"
    }
  )
}
