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
  allow_users = join(" ", var.ssh_allowed_users)
}

resource "null_resource" "ssh_hardening" {
  triggers = { host = var.host, users = local.allow_users }

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
      "sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%s)",
      "sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/'          /etc/ssh/sshd_config",
      "sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config",
      "sudo sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config",
      "sudo sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/'                  /etc/ssh/sshd_config",
      "sudo sed -i 's/^#*LoginGraceTime.*/LoginGraceTime 30/'             /etc/ssh/sshd_config",
      "sudo sed -i 's/^#*X11Forwarding.*/X11Forwarding no/'               /etc/ssh/sshd_config",
      "sudo sed -i 's/^#*AllowTcpForwarding.*/AllowTcpForwarding no/'     /etc/ssh/sshd_config",
      "sudo sed -i '/^AllowUsers/d' /etc/ssh/sshd_config",
      "echo 'AllowUsers ${local.allow_users}' | sudo tee -a /etc/ssh/sshd_config",
      "sudo sshd -t",
      "sudo systemctl reload sshd",
    ]
  }
}

resource "null_resource" "auditd" {
  depends_on = [null_resource.ssh_hardening]

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
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt-get install -y -qq auditd audispd-plugins",
      "sudo sed -i 's/^max_log_file =.*/max_log_file = ${var.audit_log_max_size_mb}/'  /etc/audit/auditd.conf",
      "sudo sed -i 's/^num_logs =.*/num_logs = ${var.audit_log_max_files}/'            /etc/audit/auditd.conf",
      "sudo sed -i 's/^max_log_file_action =.*/max_log_file_action = ROTATE/'          /etc/audit/auditd.conf",
      "printf -- '-w /etc/passwd -p wa -k identity\\n-w /etc/shadow -p wa -k identity\\n-w /etc/sudoers -p wa -k sudoers\\n-a always,exit -F arch=b64 -S execve -k exec\\n-w /var/log/auth.log -p wa -k authlog\\n' | sudo tee /etc/audit/rules.d/hardening.rules",
      "sudo augenrules --load",
      "sudo systemctl enable auditd && sudo systemctl restart auditd",
    ]
  }
}

resource "null_resource" "kernel_hardening" {
  depends_on = [null_resource.ssh_hardening]

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
      "printf 'kernel.dmesg_restrict = 1\\nkernel.kptr_restrict = 2\\nnet.ipv4.conf.all.rp_filter = 1\\nnet.ipv4.conf.default.rp_filter = 1\\nnet.ipv4.conf.all.accept_source_route = 0\\nnet.ipv4.conf.all.send_redirects = 0\\nnet.ipv4.icmp_echo_ignore_broadcasts = 1\\n' | sudo tee /etc/sysctl.d/99-hardening.conf",
      "sudo sysctl --system",
    ]
  }
}

resource "null_resource" "firewall" {
  depends_on = [null_resource.kernel_hardening]

  connection {
    type        = "ssh"
    host        = var.host
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = concat(
      [
        "set -e",
        "export DEBIAN_FRONTEND=noninteractive",
        "sudo apt-get install -y -qq ufw",
        "sudo ufw --force reset",
        "sudo ufw default deny incoming",
        "sudo ufw default allow outgoing",
        "sudo ufw allow from ${var.allowed_ssh_cidr} to any port 22 proto tcp",
      ],
      [for port in var.allowed_service_ports : "sudo ufw allow ${port}/tcp"],
      ["sudo ufw --force enable"]
    )
  }
}
