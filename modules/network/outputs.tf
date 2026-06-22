output "vpc_id" {
  value       = aws_vpc.custom_vpc.id
  description = "The ID of our custom VPC"
}

output "public_subnet_id" {
  value       = aws_subnet.public_subnet.id
  description = "The ID of our public subnet"
}
