variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string

  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "cluster_name must not be empty."
  }
}

variable "resource_group_name" {
  description = "Resource group the cluster is created in"
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "Azure region the cluster is created in"
  type        = string
  default     = "westus2"
}

variable "kubernetes_version" {
  description = "Kubernetes minor version for the AKS control plane and system node pool"
  type        = string
  default     = "1.29"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod); merged into resource tags"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

# System node pool
variable "system_node_count" {
  description = "Fixed node count for the system node pool (runs core cluster add-ons, not user workloads)"
  type        = number
  default     = 2

  validation {
    condition     = var.system_node_count > 0
    error_message = "system_node_count must be greater than zero."
  }
}

variable "system_vm_size" {
  description = "VM size for system node pool nodes"
  type        = string
  default     = "Standard_D4s_v3"
}

# User node pools for workloads
variable "node_pools" {
  description = "Map of user node pool name to its VM size, autoscaling bounds, labels, and taints"
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
  description = "VNet subnet the cluster's nodes attach to"
  type        = string

  validation {
    condition     = length(var.vnet_subnet_id) > 0
    error_message = "vnet_subnet_id must not be empty."
  }
}

# Azure AD integration for RBAC
variable "azure_ad_tenant_id" {
  description = "Azure AD tenant ID used for Azure AD-integrated cluster RBAC"
  type        = string

  validation {
    condition     = length(var.azure_ad_tenant_id) > 0
    error_message = "azure_ad_tenant_id must not be empty."
  }
}

variable "azure_ad_admin_group_ids" {
  description = "Azure AD group object IDs granted cluster-admin"
  type        = list(string)
  default     = []
}

# ACR to attach (grants AcrPull to kubelet identity)
variable "acr_id" {
  description = "ACR resource ID to grant the cluster's kubelet identity AcrPull on; empty string skips ACR integration"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for Container Insights; empty string disables it"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional resource tags merged with the environment and terraform-managed tags"
  type        = map(string)
  default     = {}
}
