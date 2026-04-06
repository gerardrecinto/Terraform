variable "cluster_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "namespace" {
  type    = string
  default = "ingress-nginx"
}

variable "replicas" {
  type    = number
  default = 2
}

# NLB instead of CLB -- required for TCP passthrough (SSH, WebSocket)
variable "use_nlb" {
  type    = bool
  default = true
}

# TCP port mappings for non-HTTP traffic: SSH (22), custom ports
# key = external port, value = "namespace/service:internal_port"
variable "tcp_services" {
  type    = map(string)
  default = {}
  # example: { "22" = "device_service/ssh-gateway:22", "8883" = "iot/mqtt:8883" }
}

variable "nlb_internal" {
  type    = bool
  default = true
}

# Cross-account NLB -- needed for PrivateLink-backed SSH gateway (DeviceService)
variable "nlb_cross_zone_enabled" {
  type    = bool
  default = true
}

# TLS termination at NGINX layer (L7); false = TCP passthrough (L4)
variable "ssl_termination" {
  type    = bool
  default = false
}

variable "certificate_arn" {
  type    = string
  default = ""
}

variable "extra_annotations" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
