variable "prefix" {
  description = "Naming prefix applied to the hub VNet and its subnets"
  type        = string
}

variable "location" {
  description = "Azure region the hub network is created in"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group the hub network is created in"
  type        = string
}

variable "hub_address_space" {
  type        = list(string)
  description = "Address space for the hub VNet."
}

variable "firewall_subnet_prefix" {
  type        = string
  description = "Must be at least /26 for Azure Firewall."
}

variable "gateway_subnet_prefix" {
  description = "CIDR for the GatewaySubnet, reserved for a future VPN/ExpressRoute gateway"
  type        = string
}

variable "bastion_subnet_prefix" {
  type        = string
  description = "Must be at least /26 for Azure Bastion."
}

variable "availability_zones" {
  description = "Availability zones zone-redundant hub resources (firewall, gateway) are spread across"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "dns_servers" {
  description = "Custom DNS servers for the hub VNet; empty list uses Azure-provided DNS"
  type        = list(string)
  default     = []
}

variable "spokes" {
  type = map(object({
    address_space = string
  }))
  description = "Map of spoke name to address_space. Each spoke gets a VNet, bidirectional peering, and a UDR."
}

variable "gateway_deployed" {
  type        = bool
  default     = false
  description = "Set true once a VPN/ExpressRoute gateway exists in the hub so spoke UDRs activate remote gateway use."
}

variable "deploy_bastion" {
  description = "Deploy Azure Bastion in the hub for browser-based VM access without public IPs"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional resource tags merged with terraform-managed tags"
  type        = map(string)
  default     = {}
}
