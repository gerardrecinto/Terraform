variable "prefix" {
  description = "Naming prefix applied to the Log Analytics workspace, action group, and alert rules"
  type        = string
}

variable "location" {
  description = "Azure region the monitoring resources are created in"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group the monitoring resources are created in"
  type        = string
}

variable "log_retention_days" {
  description = "Days Log Analytics retains ingested logs; Azure allows 30 to 730"
  type        = number
  default     = 90

  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "log_retention_days must be between 30 and 730."
  }
}

variable "alert_email_receivers" {
  description = "Email addresses the action group notifies when an alert fires"
  type = list(object({
    name    = string
    address = string
  }))
  default = []
}

variable "alert_webhook_receivers" {
  description = "Webhook URIs the action group notifies when an alert fires"
  type = list(object({
    name = string
    uri  = string
  }))
  default = []
}

variable "aks_cluster_id" {
  description = "AKS cluster resource ID to monitor for CPU usage; empty string skips AKS alerting"
  type        = string
  default     = ""
}

variable "aks_cpu_threshold_percent" {
  description = "Cluster average CPU percentage that triggers the AKS CPU alert"
  type        = number
  default     = 85

  validation {
    condition     = var.aks_cpu_threshold_percent > 0 && var.aks_cpu_threshold_percent <= 100
    error_message = "aks_cpu_threshold_percent must be between 1 and 100."
  }
}

variable "servicebus_namespace_id" {
  description = "Service Bus namespace resource ID to monitor for dead-letter queue depth; empty string skips Service Bus alerting"
  type        = string
  default     = ""
}

variable "sb_dlq_threshold" {
  description = "Number of dead-lettered messages that triggers the Service Bus DLQ alert"
  type        = number
  default     = 10

  validation {
    condition     = var.sb_dlq_threshold > 0
    error_message = "sb_dlq_threshold must be greater than zero."
  }
}

variable "tags" {
  description = "Additional resource tags merged with terraform-managed tags"
  type        = map(string)
  default     = {}
}
