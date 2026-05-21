terraform {
  required_version = ">= 1.5"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

resource "null_resource" "prerequisites" {
  triggers = { host = var.host, version = var.kubernetes_version }

  connection {
    type        = "ssh"
    host        = var.host
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "sudo swapoff -a",
      "sudo sed -i '/ swap / s/^\\(.*\\)$/#\\1/' /etc/fstab",
      "printf 'overlay\\nbr_netfilter\\n' | sudo tee /etc/modules-load.d/k8s.conf",
      "sudo modprobe overlay && sudo modprobe br_netfilter",
      "printf 'net.bridge.bridge-nf-call-iptables = 1\\nnet.bridge.bridge-nf-call-ip6tables = 1\\nnet.ipv4.ip_forward = 1\\n' | sudo tee /etc/sysctl.d/k8s.conf",
      "sudo sysctl --system",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt-get install -y -qq containerd apt-transport-https ca-certificates curl gpg",
      "sudo mkdir -p /etc/containerd",
      "containerd config default | sudo tee /etc/containerd/config.toml",
      "sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml",
      "sudo systemctl restart containerd && sudo systemctl enable containerd",
      "sudo mkdir -p /etc/apt/keyrings",
      "curl -fsSL https://pkgs.k8s.io/core:/stable:/v${var.kubernetes_version}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${var.kubernetes_version}/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt-get update -qq",
      "sudo apt-get install -y -qq kubelet kubeadm kubectl",
      "sudo apt-mark hold kubelet kubeadm kubectl",
    ]
  }
}

resource "null_resource" "join_cluster" {
  depends_on = [null_resource.prerequisites]
  triggers   = { join_command = var.join_command }

  connection {
    type        = "ssh"
    host        = var.host
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "sudo ${var.join_command}",
    ]
  }
}
