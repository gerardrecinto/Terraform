variable "subscription_id" {
  type = string
}

variable "prefix" {
  type    = string
  default = "PLACEHOLDER_PREFIX"
}

variable "location" {
  type    = string
  default = "PLACEHOLDER_AZURE_REGION"
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}

variable "networking_resource_group" {
  type        = string
  description = "RG containing the spoke VNets from hub_spoke_network."
}

variable "aks_vnet_name" {
  type = string
}

variable "aks_nodes_subnet_name" {
  type = string
}

variable "aks_pods_subnet_name" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "pod_cidr" {
  type    = string
  default = "PLACEHOLDER_POD_CIDR"
}

variable "service_cidr" {
  type    = string
  default = "PLACEHOLDER_SVC_CIDR"
}

variable "dns_service_ip" {
  type    = string
  default = "PLACEHOLDER_DNS_SVC_IP"
}

variable "system_pool_vm_size" {
  type    = string
  default = "Standard_D4ds_v5"
}

variable "system_pool_node_count" {
  type    = number
  default = 3
}

variable "workload_pool_vm_size" {
  type    = string
  default = "Standard_D8ds_v5"
}

variable "workload_pool_node_count" {
  type    = number
  default = 3
}

variable "deploy_spot_pool" {
  type    = bool
  default = false
}

variable "spot_pool_vm_size" {
  type    = string
  default = "Standard_D8ds_v5"
}

variable "spot_pool_max_count" {
  type    = number
  default = 10
}

variable "availability_zones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

variable "tags" {
  type = map(string)
  default = {
    managed-by  = "terraform"
    environment = "PLACEHOLDER_ENV"
  }
}
