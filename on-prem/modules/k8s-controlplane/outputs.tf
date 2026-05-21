output "host" {
  description = "Control plane IP or hostname"
  value       = var.host
}

output "join_command_remote_path" {
  description = "Path on the control plane where the worker join command is written"
  value       = "/tmp/k8s_join_command.sh"
}
