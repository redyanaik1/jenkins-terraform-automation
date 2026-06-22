variable "aws_region" {
  type        = string
  description = "Target AWS Region"
}

variable "prefix" {
  type        = string
  description = "Resource naming prefix"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
}
