variable "env_name" {
  description = "Name of the terraform workspace"
  type = string
}

variable "name_prefix" {
  description = "Prefixed to resource names where possible"
  type        = string
  default = ""
}

variable "domain" {
  description = "Prefix added to .tyk.technology to construct the hosted zone"
  type = string
}

variable "cidr" {
  description = "CIDR for VPC"
  type = string
}

variable "region" {
  type = string
}

variable "key_name" {
  description = "ssh pubkey added to bastion"
  type        = string
}