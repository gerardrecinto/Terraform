variable "region" {
  type    = string
  default = "cn-hangzhou"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "vpc_id" {
  type = string
}

variable "vswitch_ids" {
  type = list(string)
}
