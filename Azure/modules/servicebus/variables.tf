variable "name" {
  type        = string
  description = "Service Bus namespace name (globally unique)."
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "capacity" {
  type        = number
  default     = 1
  description = "Message units (1, 2, 4, 8, 16). Premium SKU only."
}

variable "topics" {
  type = map(object({
    max_size_mb         = number
    default_ttl         = string
    partitioned         = bool
    support_ordering    = bool
    duplicate_detection = bool
    subscriptions = map(object({
      max_delivery_count = number
      message_ttl        = string
    }))
  }))
  default = {}
}

variable "queues" {
  type = map(object({
    max_size_mb         = number
    default_ttl         = string
    max_delivery_count  = number
    partitioned         = bool
    duplicate_detection = bool
  }))
  default = {}
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "private_dns_zone_id" {
  type        = string
  description = "privatelink.servicebus.windows.net DNS zone resource ID."
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "sender_principal_ids" {
  type    = list(string)
  default = []
}

variable "receiver_principal_ids" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
