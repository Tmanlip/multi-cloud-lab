output "function_name" {
  description = "Name of the AWS Lambda function"
  value       = aws_lambda_function.health.function_name
}

output "function_arn" {
  description = "ARN of the AWS Lambda function"
  value       = aws_lambda_function.health.arn
}

output "function_url" {
  description = "Public HTTPS URL of the AWS Lambda health endpoint"
  value       = aws_lambda_function_url.health.function_url
}

output "execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda.arn
}