variable "resource_group_name" {
  description = "Azure resource group containing the Function App"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "function_app_name" {
  description = "Name of the Azure Function App"
  type        = string
}

variable "storage_account_name" {
  description = "Storage account used by the Azure Function"
  type        = string
}

variable "service_plan_name" {
  description = "Name of the Azure App Service plan"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "app_version" {
  description = "Application version"
  type        = string
  default     = "1.0.0"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}