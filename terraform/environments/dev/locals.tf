locals {
  project_short = "mcf"

  common_tags = {
    Project     = "MultiCloudForge"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Portfolio"
    CostCenter  = "Lab"
  }

  azure_resource_group_name = "rg-${local.project_short}-${var.environment}-sea"

  aws_name_prefix = "${local.project_short}-${var.environment}"
}