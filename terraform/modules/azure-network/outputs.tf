output "resource_group_name" {
  description = "Name of the Azure networking resource group"
  value       = azurerm_resource_group.network.name
}

output "vnet_id" {
  description = "ID of the Azure virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the Azure virtual network"
  value       = azurerm_virtual_network.main.name
}

output "application_subnet_id" {
  description = "ID of the application subnet"
  value       = azurerm_subnet.application.id
}

output "private_subnet_id" {
  description = "ID of the private/service subnet"
  value       = azurerm_subnet.private.id
}

output "application_nsg_id" {
  description = "ID of the application NSG"
  value       = azurerm_network_security_group.application.id
}

output "private_nsg_id" {
  description = "ID of the private NSG"
  value       = azurerm_network_security_group.private.id
}