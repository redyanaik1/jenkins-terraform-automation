output "ec2_public_ip" {
  value       = module.compute_layer.ec2_public_ip
  description = "The public IP address of our web server module"
}
