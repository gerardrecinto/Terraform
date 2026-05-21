variable "prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
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
  type = string
}

variable "bastion_subnet_prefix" {
  type        = string
  description = "Must be at least /26 for Azure Bastion."
}

variable "availability_zones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

variable "dns_servers" {
  type    = list(string)
  default = []
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
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
