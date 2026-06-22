variable "vpc_id" {
  type        = string
  description = "VPC ID from network module"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID from network module"
}

variable "prefix" {
  type        = string
  description = "Resource naming prefix"
}
