variable "project_id" {
  type = string
}

variable "org_id" {
  description = "Apigee organization ID (usually same as GCP project ID)"
  type        = string
}

variable "environment" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

# Apigee environment name (e.g., "prod", "dev")
variable "apigee_env_name" {
  type = string
}

# Apigee environment group hostname (external-facing)
variable "apigee_env_group_hostname" {
  type = string
  # e.g., "api.example.com"
}

# API proxies to deploy -- each becomes one Apigee API proxy
variable "api_proxies" {
  description = "Map of proxy name to its config"
  type = map(object({
    display_name  = string
    description   = string
    base_path     = string
    target_url    = string
    # token_auth: validates Bearer token via JS policy before forwarding
    token_auth_enabled = bool
    # path_routing: map of path prefix -> backend URL override
    path_routes = map(string)
  }))
  default = {}
}

# OAuth2 / API key validation endpoint (used in JS token auth policy)
variable "token_validation_url" {
  type    = string
  default = ""
}

variable "vpc_network_name" {
  type    = string
  default = "default"
}

variable "vpc_peering_cidr" {
  description = "CIDR range for Apigee managed VPC peering"
  type        = string
  default     = "10.0.0.0/22"
}

variable "tags" {
  type    = map(string)
  default = {}
}
