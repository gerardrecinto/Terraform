variable "prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "log_retention_days" {
  type    = number
  default = 90
}

variable "alert_email_receivers" {
  type = list(object({
    name    = string
    address = string
  }))
  default = []
}

variable "alert_webhook_receivers" {
  type = list(object({
    name = string
    uri  = string
  }))
  default = []
}

variable "aks_cluster_id" {
  type    = string
  default = ""
}

variable "aks_cpu_threshold_percent" {
  type    = number
  default = 85
}

variable "servicebus_namespace_id" {
  type    = string
  default = ""
}

variable "sb_dlq_threshold" {
  type    = number
  default = 10
}

variable "tags" {
  type    = map(string)
  default = {}
}
