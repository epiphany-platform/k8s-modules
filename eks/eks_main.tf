module "control_plane" {
  source      = "./modules/control_plane"
  name        = var.name
  kubernetes_version = var.kubernetes_version
  subnet_ids  = local.subnet_ids
  providers = {
    aws = aws
    tls = tls
  }
}

module "nodes" {
  source        = "./modules/nodes"
  name          = var.name
  subnet_ids    = local.subnet_ids
  worker_groups = var.worker_groups
  depends_on    = [module.control_plane]
  disk_size     = var.disk_size
  ami_type      = var.ami_type
  ec2_ssh_key   = var.ec2_ssh_key

  providers = {
    aws = aws
  }
}

module "autoscaler" {
  source                                      = "./modules/autoscaler"
  name                                        = var.name
  region                                      = var.region
  openid_connect_arn                          = module.control_plane.openid_connect_arn
  openid_connect_url                          = module.control_plane.openid_connect_url
  autoscaler_version                          = local.autoscaler_version
  autoscaler_chart_version                    = "9.18.0"
  autoscaler_scale_down_utilization_threshold = var.autoscaler_scale_down_utilization_threshold
  depends_on                                  = [module.control_plane, module.nodes]

  # https://discuss.hashicorp.com/t/module-does-not-support-depends-on/11692/3
  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}
