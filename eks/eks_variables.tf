variable "name" {
  description = "Prefix for resource names"
  type        = string
  default     = "default"
  validation {
    condition     = length(var.name) < 44
    error_message = "Error: Prefix name is too long. Prefix name should have less than 44 characters."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version to install"
  type        = string
}

variable "autoscaler_version" {
  description = "Kubernetes autoscaler version"
  type        = string

}
variable "subnet_ids" {
  description = "Existing subnet ids to join to"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC id to join to"
  type        = string
}

variable "region" {
  description = "Region for AWS resources"
  type        = string
}

variable "private_route_table_id" {
  description = "Private route table id for table associations"
  type        = string
}

variable "disk_size" {
  description = "Disk size"
  type        = number
}

variable "autoscaler_scale_down_utilization_threshold" {
  description = "Autoscaler scale down utilization threshold"
  type        = string
}

variable "ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group"
  type        = string
}

variable "ec2_ssh_key" {
  description = "EC2 Key Pair name that provides access for SSH communication with the worker nodes in the EKS Node Group"
  type        = string
}

variable "use_public_ips" {
  description = "Decide if resources deployed with EKS should have assigned public IPs"
  type        = bool
}

variable "worker_groups" {
  description = "Worker groups definition list"
  type = list(object({
    name                 = string
    instance_type        = string
    asg_desired_capacity = number
    asg_min_size         = number
    asg_max_size         = number
  }))
}
