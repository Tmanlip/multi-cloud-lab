# ============================================================
# Azure
# ============================================================

module "azure_network" {
  source = "../../modules/azure-network"

  resource_group_name = local.azure_resource_group_name
  location            = var.azure_location

  vnet_name          = "vnet-${local.project_short}-${var.environment}-sea"
  vnet_address_space = [var.azure_vnet_cidr]

  application_subnet_cidr = var.azure_application_subnet_cidr
  private_subnet_cidr     = var.azure_private_subnet_cidr

  tags = local.common_tags
}

# ============================================================
# AWS
# ============================================================

module "aws_network" {
  source = "../../modules/aws-network"

  vpc_cidr            = var.aws_vpc_cidr
  public_subnet_cidr  = var.aws_public_subnet_cidr
  private_subnet_cidr = var.aws_private_subnet_cidr

  availability_zone = var.aws_availability_zone
  name_prefix       = local.aws_name_prefix

  tags = local.common_tags
}