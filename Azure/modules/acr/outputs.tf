output "registry_id" {
  value = azurerm_container_registry.this.id
}

output "login_server" {
  value = azurerm_container_registry.this.login_server
}

output "principal_id" {
  value = azurerm_container_registry.this.identity[0].principal_id
}
