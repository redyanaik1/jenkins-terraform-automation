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
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "redya-terraform-state-locks" # Enables distributed state locking!
  }
}

# Configures the target AWS cloud deployment region
provider "aws" {
  region = "us-east-1"
}

# The actual infrastructure resource Jenkins will deploy and destroy
resource "aws_s3_bucket" "my_automation_bucket" {
  bucket_prefix = "jenkins-terraform-automation-"
  force_destroy = true
}
