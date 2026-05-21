output "id" {
  value = azurerm_api_management.main.id
}

output "gateway_url" {
  value = azurerm_api_management.main.gateway_url
}

output "private_ip_addresses" {
  value = azurerm_api_management.main.private_ip_addresses
}

output "identity_principal_id" {
  value = azurerm_user_assigned_identity.apim.principal_id
}

output "identity_client_id" {
  value = azurerm_user_assigned_identity.apim.client_id
}
