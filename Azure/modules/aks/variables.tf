variable "cluster_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "westus2"
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}

variable "environment" {
  type = string
}

# System node pool
variable "system_node_count" {
  type    = number
  default = 2
}

variable "system_vm_size" {
  type    = string
  default = "Standard_D4s_v3"
}

# User node pools for workloads
variable "node_pools" {
  type = map(object({
    vm_size    = string
    min_count  = number
    max_count  = number
    node_count = number
    labels     = map(string)
    taints     = list(string)
  }))
  default = {}
}

variable "vnet_subnet_id" {
  type = string
}

# Azure AD integration for RBAC
variable "azure_ad_tenant_id" {
  type = string
}

variable "azure_ad_admin_group_ids" {
  description = "Azure AD group object IDs granted cluster-admin"
  type        = list(string)
  default     = []
}

# ACR to attach (grants AcrPull to kubelet identity)
variable "acr_id" {
  type    = string
  default = ""
}

variable "log_analytics_workspace_id" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
