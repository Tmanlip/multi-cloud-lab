resource "azurerm_storage_account" "function" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  tags = var.tags
}

resource "azurerm_service_plan" "function" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location

  os_type  = "Linux"
  sku_name = "Y1"

  tags = var.tags
}

resource "azurerm_application_insights" "function" {
  name                = "${var.function_app_name}-appi"
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = "web"

  tags = var.tags
}

resource "azurerm_linux_function_app" "health" {
  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  service_plan_id = azurerm_service_plan.function.id

  storage_account_name       = azurerm_storage_account.function.name
  storage_account_access_key = azurerm_storage_account.function.primary_access_key

  functions_extension_version = "~4"

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_insights_connection_string = azurerm_application_insights.function.connection_string

    application_stack {
      python_version = "3.12"
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"

    "ENVIRONMENT" = var.environment
    "APP_VERSION" = var.app_version
    "REGION"      = var.location
  }

  tags = var.tags
}