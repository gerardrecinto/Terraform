variable "lb_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vip_subnet_id" {
  type = string
}

variable "member_subnet_id" {
  type = string
}

variable "tls_container_ref" {
  description = "Barbican secret container ref holding the TLS certificate/key pair"
  type        = string
}

variable "health_check_path" {
  type    = string
  default = "/healthz"
}

variable "backend_members" {
  type = map(object({
    address = string
    port    = number
    weight  = number
  }))
  default = {}
}
