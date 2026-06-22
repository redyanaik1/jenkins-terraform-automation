# ==========================================================================
# AWS COMPUTE LAYER (EC2 INSTANCE)
# ==========================================================================

# 7. Provision a Linux Virtual Machine inside our custom public subnet
resource "aws_instance" "automation_web_server" {
  ami           = "ami-0c614dee691cbbf37" # Amazon Linux 2023 AMI for us-east-1 (Free Tier)
  instance_type = "t2.micro"

  # Attach it to the specific subnet we provisioned earlier
  subnet_id = aws_subnet.public_subnet.id

  # Assign our custom firewall security group
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "redya-automation-server"
  }
}
