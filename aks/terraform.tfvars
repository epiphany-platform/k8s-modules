prefix                = null
rg_name               = null
vnet_name             = null
subnet_name           = null
rsa_pub_path          = null  # must-have value
kubernetes_version    = "1.22.6"
enable_node_public_ip = false
enable_rbac           = false
network_policy        = "calico"
network_plugin        = "azure"
default_node_pool = {
  "size" : 2,
  "min" : 2,
  "max" : 5,
  "vm_size" : "Standard_DS2_v2",
  "disk_gb_size" : "36",
  "auto_scaling" : true,
  "type" : "VirtualMachineScaleSets"
}
auto_scaler_profile = {
  "balance_similar_node_groups" : false,
  "max_graceful_termination_sec" : "600",
  "scale_down_delay_after_add" : "10m",
  "scale_down_delay_after_delete" : "10s",
  "scale_down_delay_after_failure" : "10m",
  "scan_interval" : "10s",
  "scale_down_unneeded" : "10m",
  "scale_down_unready" : "10m",
  "scale_down_utilization_threshold" : "0.5"
}
azure_ad       = null
identity_type  = "SystemAssigned"
admin_username = "operations"
