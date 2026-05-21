terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

# Premium SKU required for private endpoints and VNet integration
resource "azurerm_servicebus_namespace" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Premium"
  capacity            = var.capacity

  local_auth_enabled  = false
  minimum_tls_version = "1.2"

  network_rule_set {
    default_action                = "Deny"
    public_network_access_enabled = false
    trusted_services_allowed      = true
  }

  tags = var.tags
}

resource "azurerm_servicebus_topic" "main" {
  for_each = var.topics

  name                         = each.key
  namespace_id                 = azurerm_servicebus_namespace.main.id
  max_size_in_megabytes        = each.value.max_size_mb
  default_message_ttl          = each.value.default_ttl
  enable_partitioning          = each.value.partitioned
  support_ordering             = each.value.support_ordering
  requires_duplicate_detection = each.value.duplicate_detection
}

resource "azurerm_servicebus_subscription" "main" {
  for_each = {
    for sub in flatten([
      for topic_name, topic_config in var.topics : [
        for sub_name, sub_config in topic_config.subscriptions : {
          key       = "${topic_name}/${sub_name}"
          topic_key = topic_name
          sub_name  = sub_name
          config    = sub_config
        }
      ]
    ]) : sub.key => sub
  }

  name                                 = each.value.sub_name
  topic_id                             = azurerm_servicebus_topic.main[each.value.topic_key].id
  max_delivery_count                   = each.value.config.max_delivery_count
  default_message_ttl                  = each.value.config.message_ttl
  dead_lettering_on_message_expiration = true
  lock_duration                        = "PT30S"
}

resource "azurerm_servicebus_queue" "main" {
  for_each = var.queues

  name                                 = each.key
  namespace_id                         = azurerm_servicebus_namespace.main.id
  max_size_in_megabytes                = each.value.max_size_mb
  default_message_ttl                  = each.value.default_ttl
  max_delivery_count                   = each.value.max_delivery_count
  enable_partitioning                  = each.value.partitioned
  requires_duplicate_detection         = each.value.duplicate_detection
  dead_lettering_on_message_expiration = true
  lock_duration                        = "PT30S"
}

resource "azurerm_private_endpoint" "namespace" {
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = azurerm_servicebus_namespace.main.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sb-dns"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "namespace" {
  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_servicebus_namespace.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "OperationalLogs"
  }

  enabled_log {
    category = "VNetAndIPFilteringLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_role_assignment" "sender" {
  for_each             = toset(var.sender_principal_ids)
  scope                = azurerm_servicebus_namespace.main.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "receiver" {
  for_each             = toset(var.receiver_principal_ids)
  scope                = azurerm_servicebus_namespace.main.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = each.value
}
