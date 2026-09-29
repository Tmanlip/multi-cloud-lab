resource "azurerm_monitor_scheduled_query_rules_alert_v2" "function_errors" {
  name                = "${var.function_app_name}-errors"
  resource_group_name = var.resource_group_name
  location            = var.location

  scopes = [
    azurerm_application_insights.function.workspace_id
  ]

  description = "Detects HTTP 5xx responses from the MultiCloud Forge Azure Function."

  severity                = 2
  enabled                 = true
  evaluation_frequency    = "PT5M"
  window_duration         = "PT5M"
  skip_query_validation   = false
  auto_mitigation_enabled = true

  criteria {
    query = <<-KQL
      AppRequests
      | where ResultCode startswith "5"
      | summarize ErrorCount = count()
    KQL

    time_aggregation_method = "Total"
    metric_measure_column   = "ErrorCount"
    operator                = "GreaterThanOrEqual"
    threshold               = 1

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  tags = var.tags
}