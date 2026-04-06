variable "service_name" {
  description = "Name prefix for all PrivateLink resources"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Subnets where the VPC endpoint will place ENIs"
  type        = list(string)
}

variable "consumer_vpc_id" {
  description = "VPC ID of the consumer account (cross-account)"
  type        = string
  default     = ""
}

variable "allowed_principals" {
  description = "AWS account ARNs allowed to connect to the endpoint service"
  type        = list(string)
  default     = []
}

variable "nlb_arn" {
  description = "ARN of the NLB backing the endpoint service"
  type        = string
}

# SSH/WebSocket TCP passthrough ports (e.g., 22, 443)
variable "tcp_ports" {
  type    = list(number)
  default = [22, 443]
}

variable "environment" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
