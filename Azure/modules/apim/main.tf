terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

resource "azurerm_user_assigned_identity" "apim" {
  name                = "${var.prefix}-apim-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_role_assignment" "apim_kv" {
  count                = var.key_vault_id != "" ? 1 : 0
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.apim.principal_id
}

# Internal VNet mode: APIM has no public IP. Front Door Premium provides the
# public entry point via Private Link to the internal VIP.
resource "azurerm_api_management" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "${var.sku_tier}_${var.sku_capacity}"

  virtual_network_type = "Internal"
  virtual_network_configuration {
    subnet_id = var.apim_subnet_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.apim.id]
  }

  tags = var.tags
}

# Named values backed by Key Vault — APIM fetches secret at runtime, never in config
resource "azurerm_api_management_named_value" "kv_secrets" {
  for_each = var.key_vault_named_values

  name                = each.key
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.main.name
  display_name        = each.key
  secret              = true

  value_from_key_vault {
    secret_id          = each.value.secret_id
    identity_client_id = azurerm_user_assigned_identity.apim.client_id
  }
}

resource "azurerm_api_management_policy" "global" {
  api_management_id = azurerm_api_management.main.id

  xml_content = templatefile("${path.module}/templates/global-policy.xml.tpl", {
    tenant_id = var.jwt_tenant_id
    audience  = var.jwt_audience
    issuer    = "https://login.microsoftonline.com/${var.jwt_tenant_id}/v2.0"
  })
}

resource "azurerm_monitor_diagnostic_setting" "apim" {
  name                       = "${var.prefix}-apim-diag"
  target_resource_id         = azurerm_api_management.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "GatewayLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
