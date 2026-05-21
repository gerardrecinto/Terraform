terraform {
  required_version = ">= 1.5"

  backend "azurerm" {
    resource_group_name  = "PLACEHOLDER_TFSTATE_RG"
    storage_account_name = "PLACEHOLDER_TFSTATE_SA"
    container_name       = "tfstate"
    key                  = "networking/hub-spoke.tfstate"
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

resource "azurerm_resource_group" "networking" {
  name     = "${var.prefix}-networking-rg"
  location = var.location
  tags     = var.tags
}

module "hub_spoke" {
  source = "../../modules/networking"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.networking.name

  hub_address_space      = var.hub_address_space
  firewall_subnet_prefix = var.firewall_subnet_prefix
  gateway_subnet_prefix  = var.gateway_subnet_prefix
  bastion_subnet_prefix  = var.bastion_subnet_prefix

  spokes             = var.spokes
  deploy_bastion     = var.deploy_bastion
  gateway_deployed   = var.gateway_deployed
  dns_servers        = var.dns_servers
  availability_zones = var.availability_zones

  tags = var.tags
}

# Private DNS zones for Azure PaaS — linked to hub so all spokes resolve via firewall DNS proxy
resource "azurerm_private_dns_zone" "zones" {
  for_each = toset([
    "privatelink.vaultcore.azure.net",
    "privatelink.servicebus.windows.net",
    "privatelink.blob.core.windows.net",
    "privatelink.azurecr.io",
    "privatelink.azurewebsites.net",
  ])

  name                = each.value
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  for_each = azurerm_private_dns_zone.zones

  name                  = "hub-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = module.hub_spoke.hub_vnet_id
  registration_enabled  = false
}
