variable "name" {
  description = "Name prefix applied to all resources created by this module."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy into."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC, used to scope the VPC endpoint security group's ingress rule."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs to place instances (and VPC endpoints, if enabled) into."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 1
    error_message = "Provide at least 1 private subnet."
  }
}

variable "instance_count" {
  description = "Number of private instances to create, spread round-robin across private_subnet_ids."
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "enable_vpc_endpoints" {
  description = "Create VPC interface endpoints for SSM (ssm, ssmmessages, ec2messages) plus an S3 gateway endpoint. Required for Session Manager to reach these instances if the VPC has no NAT Gateway. Each interface endpoint has an hourly charge (~$0.01/hr per AZ, 2025 us-east-1 pricing) plus per-GB data processing -- the S3 gateway endpoint is free. If a NAT Gateway already provides internet egress for this VPC, you can set this to false and rely on that instead."
  type        = bool
  default     = true
}

variable "route_table_ids" {
  description = "Route table IDs to associate with the S3 gateway endpoint (only used when enable_vpc_endpoints is true). Typically the private route table(s) from the network module."
  type        = list(string)
  default     = []
}

variable "enable_session_logging" {
  description = "Log Session Manager session activity to CloudWatch Logs. Adds a CloudWatch Logs ingestion/storage cost proportional to session volume."
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention for session logs, in days."
  type        = number
  default     = 30
}

variable "kms_key_arn" {
  description = "KMS key ARN to encrypt EBS volumes and (if enable_session_logging) session log data. Leave empty to use the AWS-managed default EBS encryption key."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags applied to every resource this module creates."
  type        = map(string)
  default     = {}
}
