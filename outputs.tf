output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.security_lab.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.private_subnet.id
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value       = aws_internet_gateway.lab_gateway.id
}

output "lab_server_1_public_ip" {
  description = "Public IP of EC2 Lab Server"
  value       = aws_instance.lab_server_1.public_ip
}

output "lab_server_1_id" {
  description = "Instance ID of EC2 Lab Server"
  value       = aws_instance.lab_server_1.id
}