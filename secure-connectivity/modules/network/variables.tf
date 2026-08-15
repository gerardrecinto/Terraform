variable "name" {
  description = "Name prefix applied to all resources created by this module."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Availability Zones to spread public/private subnets across. Two is the practical minimum for a multi-AZ demonstration."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "Provide at least 2 Availability Zones for a multi-AZ layout."
  }
}

variable "public_subnet_newbits" {
  description = "Number of additional bits used to carve public subnets out of vpc_cidr via cidrsubnet()."
  type        = number
  default     = 8
}

variable "private_subnet_newbits" {
  description = "Number of additional bits used to carve private subnets out of vpc_cidr via cidrsubnet()."
  type        = number
  default     = 8
}

variable "enable_nat_gateway" {
  description = "Create NAT Gateway(s) so private subnets get outbound internet access. Each NAT Gateway has an hourly charge plus per-GB data processing charge -- disable for a cost-conscious demo where private instances only need AWS service access via VPC endpoints and Session Manager."
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "When enable_nat_gateway is true: use one shared NAT Gateway (cost-conscious, single point of failure for egress) instead of one per AZ (production-minded, no cross-AZ dependency for egress but N times the cost)."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch Logs. Adds CloudWatch Logs ingestion/storage cost proportional to traffic volume."
  type        = bool
  default     = false
}

variable "flow_logs_retention_days" {
  description = "CloudWatch Logs retention for VPC Flow Logs, in days."
  type        = number
  default     = 14
}

variable "tags" {
  description = "Additional tags applied to every resource this module creates."
  type        = map(string)
  default     = {}
}
