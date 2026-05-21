terraform {
  required_version = ">= 1.5"

  backend "azurerm" {
    resource_group_name  = "PLACEHOLDER_TFSTATE_RG"
    storage_account_name = "PLACEHOLDER_TFSTATE_SA"
    container_name       = "tfstate"
    key                  = "workloads/api-platform.tfstate"
    use_oidc             = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
  use_oidc        = true
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "api" {
  name     = "${var.prefix}-api-rg"
  location = var.location
  tags     = var.tags
}

data "azurerm_subnet" "apim" {
  name                 = var.apim_subnet_name
  virtual_network_name = var.apim_vnet_name
  resource_group_name  = var.networking_resource_group
}

data "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.dns_resource_group
}

module "monitoring" {
  source = "../../modules/monitoring"

  prefix                = var.prefix
  location              = var.location
  resource_group_name   = azurerm_resource_group.api.name
  alert_email_receivers = var.alert_email_receivers
  log_retention_days    = var.log_retention_days
  tags                  = var.tags
}

module "keyvault" {
  source = "../../modules/keyvault"

  name                       = var.keyvault_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.api.name
  private_endpoint_subnet_id = data.azurerm_subnet.apim.id
  private_dns_zone_id        = data.azurerm_private_dns_zone.kv.id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  grant_deployer_admin       = true
  tags                       = var.tags
}

module "apim" {
  source = "../../modules/apim"

  name                       = var.apim_name
  prefix                     = var.prefix
  location                   = var.location
  resource_group_name        = azurerm_resource_group.api.name
  publisher_name             = var.publisher_name
  publisher_email            = var.publisher_email
  sku_tier                   = var.apim_sku_tier
  sku_capacity               = var.apim_sku_capacity
  apim_subnet_id             = data.azurerm_subnet.apim.id
  key_vault_id               = module.keyvault.id
  jwt_tenant_id              = var.jwt_tenant_id
  jwt_audience               = var.jwt_audience
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = var.tags
}

module "frontdoor" {
  source = "../../modules/frontdoor"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.api.name
  waf_mode            = var.waf_mode
  apim_id             = module.apim.id
  apim_hostname       = var.apim_hostname
  tags                = var.tags
}
