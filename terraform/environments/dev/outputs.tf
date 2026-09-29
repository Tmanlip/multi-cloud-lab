output "azure_resource_group_name" {
  description = "Azure networking resource group"
  value       = module.azure_network.resource_group_name
}

output "azure_vnet_name" {
  description = "Azure virtual network name"
  value       = module.azure_network.vnet_name
}

output "azure_vnet_id" {
  description = "Azure virtual network ID"
  value       = module.azure_network.vnet_id
}

output "azure_application_subnet_id" {
  description = "Azure application subnet ID"
  value       = module.azure_network.application_subnet_id
}

output "azure_private_subnet_id" {
  description = "Azure private subnet ID"
  value       = module.azure_network.private_subnet_id
}

output "aws_vpc_id" {
  description = "AWS VPC ID"
  value       = module.aws_network.vpc_id
}

output "aws_public_subnet_id" {
  description = "AWS public/application subnet ID"
  value       = module.aws_network.public_subnet_id
}

output "aws_private_subnet_id" {
  description = "AWS private/service subnet ID"
  value       = module.aws_network.private_subnet_id
}

output "aws_application_security_group_id" {
  description = "AWS application security group ID"
  value       = module.aws_network.application_security_group_id
}

output "aws_private_security_group_id" {
  description = "AWS private security group ID"
  value       = module.aws_network.private_security_group_id
}

output "aws_health_function_name" {
  description = "AWS health Lambda function name"
  value       = module.aws_lambda.function_name
}

output "aws_health_url" {
  description = "AWS health endpoint"
  value       = module.aws_lambda.function_url
}

output "azure_health_function_name" {
  description = "Azure health Function App name"
  value       = module.azure_function.function_app_name
}

output "azure_health_url" {
  description = "Azure health endpoint"
  value       = module.azure_function.health_url
}

output "aws_lambda_error_alarm_name" {
  description = "AWS Lambda CloudWatch error alarm"
  value       = module.aws_lambda.error_alarm_name
}

output "azure_function_error_alert_name" {
  description = "Azure Function Monitor error alert"
  value       = module.azure_function.error_alert_name
}