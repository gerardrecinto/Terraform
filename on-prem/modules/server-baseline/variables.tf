variable "host" {
  type        = string
  description = "IP or hostname of the target server"
}

variable "ssh_user" {
  type        = string
  description = "SSH user with sudo access"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Absolute path to the SSH private key file"
}

variable "hostname" {
  type        = string
  description = "Desired hostname for this server"
}

variable "ntp_servers" {
  type        = list(string)
  description = "NTP server addresses"
  default     = ["pool.ntp.org"]
}

variable "baseline_packages" {
  type        = list(string)
  description = "OS packages to install on every node"
  default     = ["curl", "git", "jq", "vim", "htop", "net-tools", "unzip", "ca-certificates"]
}

variable "deploy_user" {
  type        = string
  description = "Non-root service account to create"
  default     = "deploy"
}

variable "deploy_user_ssh_pubkey" {
  type        = string
  description = "SSH public key for the deploy service account"
  sensitive   = true
}
