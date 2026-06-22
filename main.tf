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

# 1. Create the Custom VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "redya-automation-vpc"
  }
}

# 2. Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "redya-vpc-igw"
  }
}

# 3. Create a Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "redya-public-subnet"
  }
}

# 4. Create a Route Table
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

# 6. Create a Security Group
resource "aws_security_group" "web_sg" {
  name        = "allow_web_traffic"
  description = "Allow inbound HTTP traffic"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

# ==========================================================================
# AWS COMPUTE LAYER (EC2 INSTANCE)
# ==========================================================================

# 7. Provision a Linux Virtual Machine inside our custom public subnet
resource "aws_instance" "automation_web_server" {
  ami                    = "ami-0c614dee691cbbf37" # Amazon Linux 2023 AMI
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Automatically bootstrap and configure the Apache Web Server
  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Welcome to Redya's Automated Cloud Infrastructure! Built via Jenkins.</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "redya-automation-server"
  }
}
