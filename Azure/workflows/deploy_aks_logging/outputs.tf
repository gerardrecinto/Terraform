output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "eventhub_namespace" {
  value = azurerm_eventhub_namespace.kafka.name
}

output "grafana_service_name" {
  value = "grafana.logging.svc.cluster.local"
}
