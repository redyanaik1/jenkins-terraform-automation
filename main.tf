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

# ==========================================================================
# AWS NETWORKING & SECURITY INFRASTRUCTURE LAYER
# ==========================================================================

# 1. Create the Custom VPC (The isolated network boundary)
resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "redya-automation-vpc"
  }
}

# 2. Create an Internet Gateway (Allows the VPC to talk to the outside world)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "redya-vpc-igw"
  }
}

# 3. Create a Public Subnet (A designated section inside our VPC)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a" # Appends 'a' to your dynamic region

  tags = {
    Name = "redya-public-subnet"
  }
}

# 4. Create a Route Table (Directs network traffic out through the Internet Gateway)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "redya-public-route-table"
  }
}

# 5. Associate the Route Table with our Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 6. Create a Security Group (The firewall rules for future servers)
resource "aws_security_group" "web_sg" {
  name        = "allow_web_traffic"
  description = "Allow inbound HTTP traffic"
  vpc_id      = aws_vpc.custom_vpc.id

  # Inbound rule: Allow HTTP traffic (Port 80) from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule: Allow the infrastructure to talk out to the internet freely
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redya-web-security-group"
  }
}
