# NOTE: Published as supporting evidence for skills on resume.
# All company-specific values (account IDs, hostnames, ARNs, CIDRs, resource names)
# have been replaced with generic placeholders to preserve company CCI.
# Azure Container Registry module
# Used as the image registry for IoT telemetry AKS workloads

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_container_registry" "this" {
  name                = var.registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = false # use managed identity / service principal, not admin creds

  # Geo-replication for multi-region pulls
  dynamic "georeplications" {
    for_each = var.geo_replication_locations
    content {
      location                = georeplications.value
      zone_redundancy_enabled = true
      tags                    = var.tags
    }
  }

  network_rule_set {
    default_action = "Deny"

    dynamic "ip_rule" {
      for_each = var.allowed_ip_ranges
      content {
        action   = "Allow"
        ip_range = ip_rule.value
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Terraform   = "true"
  })
}

# Retention policy -- clean up untagged images after 30 days
resource "azurerm_container_registry_task" "cleanup" {
  count                 = var.enable_retention_policy ? 1 : 0
  name                  = "cleanup-untagged"
  container_registry_id = azurerm_container_registry.this.id

  platform {
    os = "Linux"
  }

  encoded_step {
    task_content = base64encode(<<-YAML
      version: v1.1.0
      steps:
        - cmd: acr purge --filter '.*:.*' --untagged --keep 0 --ago 30d
          disableWorkingDirectoryOverride: true
          timeout: 3600
    YAML
    )
  }

  timer_trigger {
    name     = "weekly"
    schedule = "0 2 * * 0"
    enabled  = true
  }
}
