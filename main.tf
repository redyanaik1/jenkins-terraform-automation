terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Stores the state file securely in S3 and locks it via DynamoDB
  backend "s3" {
    bucket         = "redya-terraform-state-backend"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1" # Backend configurations must use literal strings
    encrypt        = true
    dynamodb_table = "redya-terraform-state-locks" 
  }
}

# Configures the target AWS cloud deployment region dynamically
provider "aws" {
  region = var.aws_region
}

# The actual infrastructure resource Jenkins will deploy and destroy
resource "aws_s3_bucket" "my_automation_bucket" {
  bucket_prefix = var.bucket_prefix
  force_destroy = true
}
