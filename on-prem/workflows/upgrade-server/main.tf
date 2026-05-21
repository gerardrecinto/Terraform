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
  is_k8s = var.k8s_node_name != ""
}

resource "null_resource" "drain" {
  count = local.is_k8s ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${var.kubeconfig_path} drain ${var.k8s_node_name} --ignore-daemonsets --delete-emptydir-data --timeout=120s"
  }
}

resource "null_resource" "os_upgrade" {
  depends_on = [null_resource.drain]
  triggers   = { run_at = timestamp() }

  connection {
    type        = "ssh"
    host        = var.host
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    timeout     = "20m"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt-get update -qq",
      "sudo apt-get upgrade -y -qq",
      "sudo apt-get autoremove -y -qq",
    ]
  }

  provisioner "remote-exec" {
    inline = var.reboot_if_required ? [
      "if [ -f /var/run/reboot-required ]; then",
      "  echo 'Kernel updated -- rebooting in 5 seconds'",
      "  sleep 5 && sudo shutdown -r now",
      "fi",
    ] : ["echo 'Reboot skipped (reboot_if_required=false)'"]
  }
}

resource "null_resource" "wait_for_reboot" {
  count      = var.reboot_if_required ? 1 : 0
  depends_on = [null_resource.os_upgrade]

  provisioner "local-exec" {
    command = "echo 'Waiting ${var.reboot_wait_seconds}s for reboot...' && sleep ${var.reboot_wait_seconds}"
  }
}

resource "null_resource" "health_check" {
  depends_on = [null_resource.wait_for_reboot, null_resource.os_upgrade]

  connection {
    type        = "ssh"
    host        = var.host
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '=== Post-upgrade health check ===",
      "echo 'Uptime:' && uptime",
      "echo 'Disk:'   && df -h /",
      "echo 'Failed units:' && systemctl --failed --no-legend | head -20 || true",
    ]
  }
}

resource "null_resource" "uncordon" {
  count      = local.is_k8s ? 1 : 0
  depends_on = [null_resource.health_check]

  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${var.kubeconfig_path} uncordon ${var.k8s_node_name}"
  }
}
