resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name = "${aws_lambda_function.health.function_name}-errors"
  alarm_description   = "Detects errors from the ${aws_lambda_function.health.function_name} Lambda function"

  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"

  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    FunctionName = aws_lambda_function.health.function_name
  }

  treat_missing_data = "notBreaching"

  tags = var.tags
}