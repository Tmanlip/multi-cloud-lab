provider "azurerm" {
  features {}

  subscription_id = var.azure_subscription_id
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}