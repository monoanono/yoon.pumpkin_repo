variable "access_key" {
  description = "NCP API Access Key"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "NCP API Secret Key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "NCP Region"
  type        = string
}

variable "site" {
  description = "NCP Site"
  type        = string
}

variable "support_vpc" {
  description = "Support VPC"
  type        = bool
}
