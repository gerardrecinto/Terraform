output "folder_uid" {
  value = grafana_folder.alerts.uid
}

output "cloudwatch_datasource_uid" {
  value = grafana_data_source.cloudwatch.uid
}
