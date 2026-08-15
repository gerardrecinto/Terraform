variable "name" {
  description = "Name prefix applied to all resources created by this module."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy into (from the network module or an existing VPC)."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB (min 2, different AZs)."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "Provide at least 2 public subnets across different AZs for ALB high availability."
  }
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the NGINX Auto Scaling group. Instances here get no public IP."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "Provide at least 2 private subnets across different AZs for instance high availability."
  }
}

variable "instance_type" {
  description = "EC2 instance type for the NGINX Auto Scaling group."
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum instances in the Auto Scaling group."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum instances in the Auto Scaling group."
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired instance count. Set to 2+ across 2+ AZs for a high-availability demo; 1 is fine for a cost-conscious demo (no cross-AZ redundancy)."
  type        = number
  default     = 1
}

variable "health_check_path" {
  description = "HTTP path the ALB target group uses for health checks."
  type        = string
  default     = "/"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener. If empty, the module runs in HTTP-only demo mode (listener on port 80 only) -- clearly not suitable for anything beyond a local demo, since traffic is unencrypted."
  type        = string
  default     = ""
}

variable "enable_deletion_protection" {
  description = "Enable ALB deletion protection. Recommended true for a production-minded deployment; leave false for a demo you intend to tear down quickly."
  type        = bool
  default     = false
}

variable "enable_access_logs" {
  description = "Enable ALB access logs to the provided S3 bucket. Requires access_logs_bucket to be set."
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket name for ALB access logs. Required if enable_access_logs is true. The bucket must already exist with the correct ALB log-delivery bucket policy (see AWS docs for the ELB service account per region)."
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention for instance/NGINX logs shipped via the CloudWatch agent."
  type        = number
  default     = 14
}

variable "enable_detailed_monitoring" {
  description = "Enable EC2 detailed (1-minute) CloudWatch monitoring. Adds a small per-instance cost over the default 5-minute metrics."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to every resource this module creates."
  type        = map(string)
  default     = {}
}
