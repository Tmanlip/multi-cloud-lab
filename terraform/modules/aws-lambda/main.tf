resource "aws_iam_role" "lambda" {
  name = "${var.function_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "lambda_logging" {
  name = "${var.function_name}-logging"

  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "${aws_cloudwatch_log_group.lambda.arn}:*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 7

  tags = var.tags
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = var.source_file
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "health" {
  function_name = var.function_name
  role          = aws_iam_role.lambda.arn

  runtime = "python3.13"
  handler = "lambda_function.lambda_handler"

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  timeout     = 5
  memory_size = 128

  environment {
    variables = {
      ENVIRONMENT = var.environment
      APP_VERSION = var.app_version
    }
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy.lambda_logging,
    aws_cloudwatch_log_group.lambda
  ]
}

resource "aws_lambda_function_url" "health" {
  function_name      = aws_lambda_function.health.function_name
  authorization_type = "NONE"
}