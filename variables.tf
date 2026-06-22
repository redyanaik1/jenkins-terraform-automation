variable "aws_region" {
  type        = string
  description = "The target AWS region for deployment"
  default     = "us-east-1"
}

variable "bucket_prefix" {
  type        = string
  description = "The prefix string for the automation S3 bucket name"
  default     = "jenkins-terraform-automation-"
}
