terraform {
  required_version = ">= 1.5"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

locals {
  minor = join(".", slice(split(".", var.target_kubernetes_version), 0, 2))
}

# Step 1 — upgrade the control plane
resource "null_resource" "upgrade_control_plane" {
  triggers = { version = var.target_kubernetes_version }

  connection {
    type        = "ssh"
    host        = var.control_plane_host
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    timeout     = "20m"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "export DEBIAN_FRONTEND=noninteractive",
      "curl -fsSL https://pkgs.k8s.io/core:/stable:/v${local.minor}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${local.minor}/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt-get update -qq",
      "sudo apt-mark unhold kubeadm",
      "sudo apt-get install -y -qq kubeadm=${var.target_kubernetes_version}-*",
      "sudo apt-mark hold kubeadm",
      "sudo kubeadm upgrade plan v${var.target_kubernetes_version}",
      "sudo kubeadm upgrade apply v${var.target_kubernetes_version} --yes",
      "sudo apt-mark unhold kubelet kubectl",
      "sudo apt-get install -y -qq kubelet=${var.target_kubernetes_version}-* kubectl=${var.target_kubernetes_version}-*",
      "sudo apt-mark hold kubelet kubectl",
      "sudo systemctl daemon-reload && sudo systemctl restart kubelet",
    ]
  }
}

# Step 2 — upgrade each worker: drain → upgrade → uncordon
resource "null_resource" "upgrade_worker" {
  count      = length(var.worker_hosts)
  depends_on = [null_resource.upgrade_control_plane]

  triggers = {
    version = var.target_kubernetes_version
    host    = var.worker_hosts[count.index]
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${var.kubeconfig_path} drain ${var.worker_node_names[count.index]} --ignore-daemonsets --delete-emptydir-data --timeout=180s"
  }

  connection {
    type        = "ssh"
    host        = var.worker_hosts[count.index]
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    timeout     = "15m"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "export DEBIAN_FRONTEND=noninteractive",
      "curl -fsSL https://pkgs.k8s.io/core:/stable:/v${local.minor}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${local.minor}/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt-get update -qq",
      "sudo apt-mark unhold kubeadm",
      "sudo apt-get install -y -qq kubeadm=${var.target_kubernetes_version}-*",
      "sudo apt-mark hold kubeadm",
      "sudo kubeadm upgrade node",
      "sudo apt-mark unhold kubelet kubectl",
      "sudo apt-get install -y -qq kubelet=${var.target_kubernetes_version}-* kubectl=${var.target_kubernetes_version}-*",
      "sudo apt-mark hold kubelet kubectl",
      "sudo systemctl daemon-reload && sudo systemctl restart kubelet",
    ]
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${var.kubeconfig_path} uncordon ${var.worker_node_names[count.index]}"
  }
}
