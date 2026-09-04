variable "environment" {
  type    = string
  default = "prod"
}

variable "external_network_id" {
  type = string
}

variable "keypair_name" {
  type = string
}

variable "vip_subnet_id" {
  type = string
}

variable "member_subnet_id" {
  type = string
}

variable "tls_container_ref" {
  type = string
}

variable "ingress_node_addresses" {
  type    = list(string)
  default = []
}
