# Without metrics server autoscaler does not work
module "metrics_server" {
  source  = "cookielab/metrics-server/kubernetes"
  version = "0.11.1"
}
