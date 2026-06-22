variable "vpc_id" {}
variable "subnet_id" {}
variable "prefix" {}

resource "aws_security_group" "web_sg" {
  name        = "allow_web_traffic"
  description = "Allow inbound HTTP traffic"
  vpc_id      = var.vpc_id

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
  tags = { Name = "${var.prefix}web-security-group" }
}

resource "aws_instance" "automation_web_server" {
  ami                    = "ami-0c614dee691cbbf37" # Amazon Linux 2023 AMI
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Welcome to Redya's Automated Cloud Infrastructure! Built via Modular Jenkins.</h1>" > /var/www/html/index.html
              EOF

  tags = { Name = "${var.prefix}automation-server" }
}
