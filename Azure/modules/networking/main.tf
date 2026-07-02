terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

resource "azurerm_virtual_network" "hub" {
  name                = "${var.prefix}-hub-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.hub_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.firewall_subnet_prefix]
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.gateway_subnet_prefix]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.bastion_subnet_prefix]
}

resource "azurerm_public_ip" "firewall" {
  name                = "${var.prefix}-fw-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.availability_zones
  tags                = var.tags
}

resource "azurerm_public_ip" "bastion" {
  count               = var.deploy_bastion ? 1 : 0
  name                = "${var.prefix}-bastion-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.availability_zones
  tags                = var.tags
}

resource "azurerm_firewall_policy" "main" {
  name                = "${var.prefix}-fw-policy"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium"

  threat_intelligence_mode = "Alert"

  dns {
    proxy_enabled = true
    servers       = var.dns_servers
  }

  tags = var.tags
}

resource "azurerm_firewall" "main" {
  name                = "${var.prefix}-firewall"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  firewall_policy_id  = azurerm_firewall_policy.main.id
  zones               = var.availability_zones

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  tags = var.tags
}

resource "azurerm_firewall_policy_rule_collection_group" "base" {
  name               = "base-rules"
  firewall_policy_id = azurerm_firewall_policy.main.id
  priority           = 300

  network_rule_collection {
    name     = "allow-spoke-to-spoke"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "inter-spoke"
      protocols             = ["TCP", "UDP"]
      source_addresses      = [for s in var.spokes : s.address_space]
      destination_addresses = [for s in var.spokes : s.address_space]
      destination_ports     = ["*"]
    }
  }

  application_rule_collection {
    name     = "allow-outbound-web"
    priority = 200
    action   = "Allow"

    rule {
      name              = "package-registries"
      source_addresses  = [for s in var.spokes : s.address_space]
      destination_fqdns = ["*.ubuntu.com", "packages.microsoft.com", "*.docker.io", "mcr.microsoft.com"]
      protocols {
        type = "Https"
        port = 443
      }
    }
  }
}

# Spoke VNets — DNS set to firewall private IP so FQDN rules apply to spoke traffic
resource "azurerm_virtual_network" "spoke" {
  for_each = var.spokes

  name                = "${var.prefix}-${each.key}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [each.value.address_space]
  dns_servers         = [azurerm_firewall.main.ip_configuration[0].private_ip_address]
  tags                = merge(var.tags, { workload = each.key })
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each = var.spokes

  name                      = "hub-to-${each.key}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke[each.key].id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
  use_remote_gateways       = false
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each = var.spokes

  name                      = "${each.key}-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.spoke[each.key].name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  # Enable once VPN/ExpressRoute gateway is provisioned in hub
  use_remote_gateways = var.gateway_deployed
}

# UDR forces all egress through Azure Firewall for inspection
resource "azurerm_route_table" "spoke" {
  for_each = var.spokes

  name                          = "${var.prefix}-${each.key}-rt"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = true
  tags                          = var.tags

  route {
    name                   = "default-via-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.main.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_bastion_host" "main" {
  count               = var.deploy_bastion ? 1 : 0
  name                = "${var.prefix}-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tunneling_enabled   = true

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }

  tags = var.tags
}
