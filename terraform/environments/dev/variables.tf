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