variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "source_file" {
  description = "Path to the Lambda Python source file"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "app_version" {
  description = "Application version"
  type        = string
  default     = "1.0.0"
}

variable "tags" {
  description = "Common tags applied to AWS resources"
  type        = map(string)
  default     = {}
}