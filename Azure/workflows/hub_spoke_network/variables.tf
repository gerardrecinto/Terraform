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

variable "hub_address_space" {
  type    = list(string)
  default = ["PLACEHOLDER_HUB_CIDR"]
}

variable "firewall_subnet_prefix" {
  type    = string
  default = "PLACEHOLDER_FW_SUBNET"
}

variable "gateway_subnet_prefix" {
  type    = string
  default = "PLACEHOLDER_GW_SUBNET"
}

variable "bastion_subnet_prefix" {
  type    = string
  default = "PLACEHOLDER_BASTION_SUBNET"
}

variable "spokes" {
  type = map(object({
    address_space = string
  }))
  default = {
    "aks"  = { address_space = "PLACEHOLDER_AKS_SPOKE_CIDR" }
    "api"  = { address_space = "PLACEHOLDER_API_SPOKE_CIDR" }
    "data" = { address_space = "PLACEHOLDER_DATA_SPOKE_CIDR" }
  }
}

variable "dns_servers" {
  type    = list(string)
  default = []
}

variable "deploy_bastion" {
  type    = bool
  default = true
}

variable "gateway_deployed" {
  type    = bool
  default = false
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
