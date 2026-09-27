variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure region for networking resources"
  type        = string
}

variable "vnet_name" {
  description = "Name of the Azure virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space assigned to the Azure VNet"
  type        = list(string)
}

variable "application_subnet_cidr" {
  description = "CIDR block for the application subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private/service subnet"
  type        = string
}

variable "tags" {
  description = "Common tags applied to Azure resources"
  type        = map(string)
  default     = {}
}