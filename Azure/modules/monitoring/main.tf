terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

resource "azurerm_application_insights" "main" {
  name                = "${var.prefix}-appinsights"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "critical" {
  name                = "${var.prefix}-critical-ag"
  resource_group_name = var.resource_group_name
  short_name          = "critical"

  dynamic "email_receiver" {
    for_each = var.alert_email_receivers
    content {
      name          = email_receiver.value.name
      email_address = email_receiver.value.address
    }
  }

  dynamic "webhook_receiver" {
    for_each = var.alert_webhook_receivers
    content {
      name        = webhook_receiver.value.name
      service_uri = webhook_receiver.value.uri
    }
  }
}

resource "azurerm_monitor_metric_alert" "aks_cpu" {
  count               = var.aks_cluster_id != "" ? 1 : 0
  name                = "${var.prefix}-aks-cpu-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.aks_cluster_id]
  description         = "AKS node CPU > ${var.aks_cpu_threshold_percent}%"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.aks_cpu_threshold_percent
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }
}

resource "azurerm_monitor_metric_alert" "sb_dlq" {
  count               = var.servicebus_namespace_id != "" ? 1 : 0
  name                = "${var.prefix}-sb-dlq-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.servicebus_namespace_id]
  description         = "Service Bus DLQ count > ${var.sb_dlq_threshold}"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "DeadletteredMessages"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.sb_dlq_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "oom_killed" {
  count                = var.aks_cluster_id != "" ? 1 : 0
  name                 = "${var.prefix}-aks-oomkilled"
  location             = var.location
  resource_group_name  = var.resource_group_name
  description          = "Containers OOMKilled in last 5 minutes"
  severity             = 2
  enabled              = true
  scopes               = [azurerm_log_analytics_workspace.main.id]
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"

  criteria {
    query = <<-QUERY
      KubeEvents
      | where TimeGenerated > ago(5m)
      | where Reason == "OOMKilling"
      | summarize count() by bin(TimeGenerated, 1m), Name
      | where count_ > 0
    QUERY

    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.critical.id]
  }

  tags = var.tags
}
