variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "multicloud-forge"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "azure_subscription_id" {
  description = "Azure subscription ID used for deployment"
  type        = string
}

variable "azure_location" {
  description = "Azure deployment region"
  type        = string
  default     = "southeastasia"
}

variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-southeast-1"
}

variable "azure_vnet_cidr" {
  description = "CIDR block for the Azure VNet"
  type        = string
  default     = "10.10.0.0/16"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for the AWS VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "azure_application_subnet_cidr" {
  description = "CIDR block for the Azure application subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "azure_private_subnet_cidr" {
  description = "CIDR block for the Azure private/service subnet"
  type        = string
  default     = "10.10.2.0/24"
}

variable "aws_public_subnet_cidr" {
  description = "CIDR block for the AWS public/application subnet"
  type        = string
  default     = "10.20.1.0/24"
}

variable "aws_private_subnet_cidr" {
  description = "CIDR block for the AWS private/service subnet"
  type        = string
  default     = "10.20.2.0/24"
}

variable "aws_availability_zone" {
  description = "AWS Availability Zone used by the development environment"
  type        = string
  default     = "ap-southeast-1a"
}

variable "azure_function_app_name" {
  description = "Globally unique Azure Function App name"
  type        = string
}

variable "azure_function_storage_name" {
  description = "Globally unique Azure Function storage account name"
  type        = string
}

variable "app_version" {
  description = "Application version deployed across AWS and Azure"
  type        = string
  default     = "1.0.1"
}