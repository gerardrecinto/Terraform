variable "project_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "api_hostname" {
  description = "External hostname for the Apigee environment group (e.g., api.example.com)"
  type        = string
}

variable "token_validation_url" {
  description = "Token introspection endpoint -- JS policy validates Bearer tokens here"
  type        = string
  sensitive   = true
}

variable "vpc_network" {
  type    = string
  default = "default"
}

variable "vpc_peering_cidr" {
  type    = string
  default = "10.0.0.0/22"
}

# Backend host for each proxy (internal service URLs)
variable "devicecloud_backend_host" {
  type      = string
  sensitive = true
}

variable "softwarehub_backend_host" {
  type      = string
  sensitive = true
}

variable "modelhub_backend_host" {
  type      = string
  sensitive = true
}
