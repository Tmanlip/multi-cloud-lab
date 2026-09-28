output "function_app_name" {
  description = "Name of the Azure Function App"
  value       = azurerm_linux_function_app.health.name
}

output "function_app_hostname" {
  description = "Default hostname of the Azure Function App"
  value       = azurerm_linux_function_app.health.default_hostname
}

output "health_url" {
  description = "Azure health endpoint"
  value       = "https://${azurerm_linux_function_app.health.default_hostname}/api/health"
}

output "managed_identity_principal_id" {
  description = "Principal ID of the Function App managed identity"
  value       = azurerm_linux_function_app.health.identity[0].principal_id
}