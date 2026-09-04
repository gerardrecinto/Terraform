variable "subscription_id" {
  description = "Azure subscription ID the hub and spoke VNets are provisioned in"
  type        = string

  validation {
    condition     = length(var.subscription_id) > 0
    error_message = "subscription_id must not be empty."
  }
}

variable "prefix" {
  description = "Naming prefix applied to the hub VNet, its subnets, and each spoke VNet"
  type        = string
  default     = "PLACEHOLDER_PREFIX"
}

variable "location" {
  description = "Azure region the hub and spoke VNets are created in"
  type        = string
  default     = "PLACEHOLDER_AZURE_REGION"
}

variable "hub_address_space" {
  description = "Address space for the hub VNet"
  type        = list(string)
  default     = ["PLACEHOLDER_HUB_CIDR"]
}

variable "firewall_subnet_prefix" {
  description = "CIDR for AzureFirewallSubnet; must be at least /26"
  type        = string
  default     = "PLACEHOLDER_FW_SUBNET"
}

variable "gateway_subnet_prefix" {
  description = "CIDR for the GatewaySubnet, reserved for a future VPN/ExpressRoute gateway"
  type        = string
  default     = "PLACEHOLDER_GW_SUBNET"
}

variable "bastion_subnet_prefix" {
  description = "CIDR for AzureBastionSubnet; must be at least /26"
  type        = string
  default     = "PLACEHOLDER_BASTION_SUBNET"
}

variable "spokes" {
  description = "Map of spoke name to address_space; each spoke gets a VNet, bidirectional peering to the hub, and a UDR"
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
  description = "Custom DNS servers for the hub VNet; empty list uses Azure-provided DNS"
  type        = list(string)
  default     = []
}

variable "deploy_bastion" {
  description = "Deploy Azure Bastion in the hub for browser-based VM access without public IPs"
  type        = bool
  default     = true
}

variable "gateway_deployed" {
  description = "Set true once a VPN/ExpressRoute gateway exists in the hub so spoke UDRs activate remote gateway use"
  type        = bool
  default     = false
}

variable "availability_zones" {
  description = "Availability zones zone-redundant hub resources (firewall, gateway) are spread across"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "tags" {
  description = "Additional resource tags merged with terraform-managed tags"
  type        = map(string)
  default = {
    managed-by  = "terraform"
    environment = "PLACEHOLDER_ENV"
  }
}
