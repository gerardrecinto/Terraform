variable "name" {
  type        = string
  description = "Service Bus namespace name (globally unique)."
}

variable "location" {
  description = "Azure region the Service Bus namespace is created in"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group the Service Bus namespace is created in"
  type        = string
}

variable "capacity" {
  type        = number
  default     = 1
  description = "Message units (1, 2, 4, 8, 16). Premium SKU only."
}

variable "topics" {
  description = "Map of topic name to its size limit, TTL, partitioning, ordering, duplicate detection, and subscriptions"
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
  description = "Map of queue name to its size limit, TTL, max delivery count, partitioning, and duplicate detection"
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
  description = "Subnet the namespace's private endpoint NIC attaches to"
  type        = string
}

variable "private_dns_zone_id" {
  type        = string
  description = "privatelink.servicebus.windows.net DNS zone resource ID."
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID namespace diagnostic logs are sent to"
  type        = string
}

variable "sender_principal_ids" {
  description = "Principal IDs granted Azure Service Bus Data Sender on the namespace"
  type        = list(string)
  default     = []
}

variable "receiver_principal_ids" {
  description = "Principal IDs granted Azure Service Bus Data Receiver on the namespace"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional resource tags merged with terraform-managed tags"
  type        = map(string)
  default     = {}
}
