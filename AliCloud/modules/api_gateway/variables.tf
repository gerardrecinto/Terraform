variable "group_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "stage_name" {
  type    = string
  default = "RELEASE"
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
