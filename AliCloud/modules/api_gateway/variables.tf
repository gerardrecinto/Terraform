variable "group_name" {
  description = "Base name for the API group; the environment is appended to form the actual group name"
  type        = string

  validation {
    condition     = length(var.group_name) > 0
    error_message = "group_name must not be empty."
  }
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod); appended to the group name and API names"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "stage_name" {
  description = "API Gateway stage the routed APIs and app credential are published to"
  type        = string
  default     = "RELEASE"
}

variable "apis" {
  description = "Map of API name to its routing and backend config"
  type = map(object({
    description     = string
    request_path    = string
    backend_address = string
    backend_path    = string
  }))
  default = {}
}
