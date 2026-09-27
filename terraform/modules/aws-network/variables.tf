variable "vpc_cidr" {
  description = "CIDR block for the AWS VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public/application subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private/service subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone used by the development environment"
  type        = string
}

variable "name_prefix" {
  description = "Prefix used when naming AWS resources"
  type        = string
}

variable "tags" {
  description = "Common tags applied to AWS resources"
  type        = map(string)
  default     = {}
}