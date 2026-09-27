output "vpc_id" {
  description = "ID of the AWS VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public/application subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private/service subnet"
  value       = aws_subnet.private.id
}

output "application_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.application.id
}

output "private_security_group_id" {
  description = "ID of the private security group"
  value       = aws_security_group.private.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}