variable "lb_name" {
  description = "Name of the Octavia load balancer, listener, and pool"
  type        = string

  validation {
    condition     = length(var.lb_name) > 0
    error_message = "lb_name must not be empty."
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

variable "vip_subnet_id" {
  description = "Subnet the load balancer's virtual IP is allocated from"
  type        = string

  validation {
    condition     = length(var.vip_subnet_id) > 0
    error_message = "vip_subnet_id must not be empty."
  }
}

variable "member_subnet_id" {
  description = "Subnet the backend pool members are reachable on"
  type        = string

  validation {
    condition     = length(var.member_subnet_id) > 0
    error_message = "member_subnet_id must not be empty."
  }
}

variable "tls_container_ref" {
  description = "Barbican secret container ref holding the TLS certificate/key pair"
  type        = string
}

variable "health_check_path" {
  description = "HTTP path the pool's health monitor polls on each backend member"
  type        = string
  default     = "/healthz"
}

variable "backend_members" {
  description = "Map of member name to its address, port, and load-balancing weight"
  type = map(object({
    address = string
    port    = number
    weight  = number
  }))
  default = {}
}
