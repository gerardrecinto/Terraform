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
  pkg_list = join(" ", var.baseline_packages)
  ntp_conf = join("\n", concat(
    ["[Time]"],
    ["NTP=${join(" ", var.ntp_servers)}"],
    ["FallbackNTP=pool.ntp.org"]
  ))
}

resource "null_resource" "packages" {
  triggers = { host = var.host }

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
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt-get update -qq",
      "sudo apt-get install -y -qq ${local.pkg_list}",
    ]
  }
}

resource "null_resource" "hostname" {
  depends_on = [null_resource.packages]
  triggers   = { hostname = var.hostname }

  connection {
    type        = "ssh"
    host        = var.host
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "sudo hostnamectl set-hostname ${var.hostname}",
      "grep -q '${var.hostname}' /etc/hosts || echo '127.0.1.1 ${var.hostname}' | sudo tee -a /etc/hosts",
    ]
  }
}

resource "null_resource" "ntp" {
  depends_on = [null_resource.packages]
  triggers   = { servers = join(",", var.ntp_servers) }

  connection {
    type        = "ssh"
    host        = var.host
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "printf '[Time]\\nNTP=${join(" ", var.ntp_servers)}\\nFallbackNTP=pool.ntp.org\\n' | sudo tee /etc/systemd/timesyncd.conf",
      "sudo systemctl restart systemd-timesyncd",
      "sudo timedatectl set-ntp true",
    ]
  }
}

resource "null_resource" "deploy_user" {
  depends_on = [null_resource.packages]
  triggers   = { user = var.deploy_user, pubkey = var.deploy_user_ssh_pubkey }

  connection {
    type        = "ssh"
    host        = var.host
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "id ${var.deploy_user} &>/dev/null || sudo useradd -m -s /bin/bash ${var.deploy_user}",
      "sudo usermod -aG sudo ${var.deploy_user}",
      "sudo mkdir -p /home/${var.deploy_user}/.ssh",
      "echo '${var.deploy_user_ssh_pubkey}' | sudo tee /home/${var.deploy_user}/.ssh/authorized_keys",
      "sudo chmod 700 /home/${var.deploy_user}/.ssh",
      "sudo chmod 600 /home/${var.deploy_user}/.ssh/authorized_keys",
      "sudo chown -R ${var.deploy_user}:${var.deploy_user} /home/${var.deploy_user}/.ssh",
      "echo '${var.deploy_user} ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/${var.deploy_user}",
      "sudo chmod 440 /etc/sudoers.d/${var.deploy_user}",
    ]
  }
}
