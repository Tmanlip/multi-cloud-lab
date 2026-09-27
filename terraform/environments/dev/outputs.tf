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