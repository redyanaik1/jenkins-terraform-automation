output "ec2_public_ip" {
  value       = aws_instance.automation_web_server.public_ip
  description = "The public IP address of the compute instance"
}
