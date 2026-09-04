variable "cluster_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_image" {
  description = "Fedora CoreOS or Ubuntu image name registered in Glance with a Magnum-compatible driver"
  type        = string
  default     = "fedora-coreos-stable"
}

variable "master_flavor" {
  type    = string
  default = "m1.large"
}

variable "node_flavor" {
  type    = string
  default = "m1.xlarge"
}

variable "external_network_id" {
  type = string
}

variable "dns_nameserver" {
  type    = string
  default = "8.8.8.8"
}

variable "kubernetes_version" {
  type    = string
  default = "v1.30.1"
}

variable "availability_zone" {
  type    = string
  default = "nova"
}

variable "master_count" {
  type    = number
  default = 3
}

variable "initial_node_count" {
  type    = number
  default = 3
}

variable "keypair_name" {
  type = string
}
