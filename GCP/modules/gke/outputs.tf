output "cluster_name" {
  value = google_container_cluster.this.name
}

output "cluster_endpoint" {
  value     = google_container_cluster.this.endpoint
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = google_container_cluster.this.master_auth[0].cluster_ca_certificate
  sensitive = true
}

output "node_service_account_email" {
  value = google_service_account.gke_nodes.email
}

output "workload_identity_pool" {
  value = var.workload_identity_enabled ? "${var.project_id}.svc.id.goog" : null
}
