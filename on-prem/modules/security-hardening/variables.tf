variable "host" {
  type        = string
  description = "IP or hostname of the server to harden"
}

variable "ssh_user" {
  type        = string
  description = "SSH user with sudo access"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Absolute path to the SSH private key"
}

variable "ssh_allowed_users" {
  type        = list(string)
  description = "OS users permitted to log in via SSH"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR range allowed to reach port 22"
  default     = "10.0.0.0/8"
}

variable "allowed_service_ports" {
  type        = list(number)
  description = "Additional TCP ports to allow inbound (e.g. 6443 for K8s API server)"
  default     = []
}

variable "audit_log_max_size_mb" {
  type        = number
  description = "Max size per audit log file in MB before rotation"
  default     = 50
}

variable "audit_log_max_files" {
  type        = number
  description = "Number of rotated audit log files to retain"
  default     = 5
}
