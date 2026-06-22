terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Secure State Management
  backend "s3" {
    bucket         = "redya-terraform-state-backend"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "redya-terraform-state-locks" 
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 Automation Bucket
resource "aws_s3_bucket" "my_automation_bucket" {
  bucket_prefix = var.bucket_prefix
  force_destroy = true
}

# ==========================================================================
# MODULES CALLS
# ==========================================================================

# Call our Network Module
module "network_layer" {
  source     = "./modules/network"
  aws_region = var.aws_region
  prefix     = "redya-mod-"
}

# Call our Compute Module & Pass output attributes from the Network Module
module "compute_layer" {
  source    = "./modules/compute"
  prefix    = "redya-mod-"
  vpc_id    = module.network_layer.vpc_id
  subnet_id = module.network_layer.public_subnet_id
}
