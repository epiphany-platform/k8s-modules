name                                        = null # must-have value
kubernetes_version                          = "1.22"
autoscaler_version                          = null
subnet_ids                                  = null
vpc_id                                      = null  # must-have value from Epiphany infrastructure
region                                      = null  # must-have value from Epiphany infrastructure
private_route_table_id                      = null  # must-have value from Epiphany infrastructure
disk_size                                   = 32
autoscaler_scale_down_utilization_threshold = 0.65
ami_type                                    = "AL2_x86_64"
ec2_ssh_key                                 = null  # must-have value from Epiphany infrastructure
use_public_ips                              = true

worker_groups = [
  {
    name                 = null,
    instance_type        = "t2.small",
    asg_desired_capacity = 1,
    asg_min_size         = 1,
    asg_max_size         = 1,
  }
]
