output "host" {
  description = "Control plane IP or hostname"
  value       = var.host
}

output "join_command_remote_path" {
  description = "Path on the control plane where the worker join command is written"
  value       = "/tmp/k8s_join_command.sh"
}

output "join_command" {
  description = "Full kubeadm join command, fetched from the control plane over SSH"
  value       = trimspace(data.local_file.join_command.content)
  sensitive   = true
}
