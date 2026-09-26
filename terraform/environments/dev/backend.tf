terraform {
  backend "azurerm" {
    resource_group_name  = "rg-mcf-tfstate-sea"
    storage_account_name = "stmcfstate85775"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"

    use_azuread_auth = true
  }
}