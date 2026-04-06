variable "subscription_id" {
  type = string
}

variable "project_name" {
  type    = string
  default = "aware-iot"
}

variable "environment" {
  type = string
}

variable "location" {
  type    = string
  default = "westus2"
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}

variable "azure_ad_tenant_id" {
  type = string
}
