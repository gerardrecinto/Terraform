variable "region" {
  description = "AliCloud region to provision the cluster and its RAM role in"
  type        = string
  default     = "cn-hangzhou"

  validation {
    condition     = length(var.region) > 0
    error_message = "region must not be empty."
  }
}

variable "cluster_name" {
  description = "Name of the ACK cluster; also used as the prefix for its worker RAM role"
  type        = string

  validation {
    condition     = length(var.cluster_name) > 0 && length(var.cluster_name) <= 63
    error_message = "cluster_name must be 1-63 characters."
  }
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod); merged into resource tags"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "cluster_spec" {
  description = "ack.standard for basic managed control plane, ack.pro.small for SLA-backed pro edition"
  type        = string
  default     = "ack.pro.small"
}

variable "kubernetes_version" {
  description = "Kubernetes version string as published by ACK (not a bare semver, includes the -aliyun.N suffix)"
  type        = string
  default     = "1.30.1-aliyun.1"
}

variable "vswitch_ids" {
  description = "VSwitch IDs the cluster's control plane and node pools attach to; must span at least one zone"
  type        = list(string)

  validation {
    condition     = length(var.vswitch_ids) > 0
    error_message = "vswitch_ids must contain at least one vswitch."
  }
}

variable "service_cidr" {
  description = "CIDR block for Kubernetes Service cluster IPs; must not overlap the VPC's vswitch CIDRs"
  type        = string
  default     = "172.21.0.0/20"

  validation {
    condition     = can(cidrhost(var.service_cidr, 0))
    error_message = "service_cidr must be a valid CIDR block."
  }
}

variable "node_role_policies" {
  description = "System RAM policy names attached to the worker node role"
  type        = list(string)
  default = [
    "AliyunCSManagedKubernetesRolePolicy",
    "AliyunContainerRegistryReadOnlyAccess",
  ]
}

variable "node_pools" {
  description = "Map of node pool name to its instance sizing, autoscaling bounds, and optional taints"
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
  description = "Additional resource tags merged with the environment and terraform-managed tags"
  type        = map(string)
  default     = {}
}
