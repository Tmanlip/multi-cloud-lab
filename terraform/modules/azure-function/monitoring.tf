resource "azurerm_monitor_metric_alert" "function_errors" {
  name                = "${azurerm_linux_function_app.health.name}-errors"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_linux_function_app.health.id]

  description = "Detects HTTP server errors from the MultiCloud Forge Azure Function."
  severity    = 2
  enabled     = true

  frequency   = "PT1M"
  window_size = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThanOrEqual"
    threshold        = 1
  }

  tags = var.tags
}