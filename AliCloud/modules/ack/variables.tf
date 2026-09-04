variable "region" {
  type    = string
  default = "cn-hangzhou"
}

variable "cluster_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_spec" {
  description = "ack.standard for basic managed control plane, ack.pro.small for SLA-backed pro edition"
  type        = string
  default     = "ack.pro.small"
}

variable "kubernetes_version" {
  type    = string
  default = "1.30.1-aliyun.1"
}

variable "vswitch_ids" {
  type = list(string)
}

variable "service_cidr" {
  type    = string
  default = "172.21.0.0/20"
}

variable "node_role_policies" {
  type = list(string)
  default = [
    "AliyunCSManagedKubernetesRolePolicy",
    "AliyunContainerRegistryReadOnlyAccess",
  ]
}

variable "node_pools" {
  type = map(object({
    instance_types       = list(string)
    system_disk_category = string
    system_disk_size     = number
    min_count            = number
    max_count            = number
    initial_count        = number
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
