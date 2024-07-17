variable "account_id" {
  description = "id of AWS account"
  type        = string
  default     = "283466803266"
}

variable "company" {
  description = "company name"
  type        = string
  default     = "samuel+clar"
}

variable "project" {
  description = "Environment for resources"
  type        = string
  default     = "esthetician-app-backend"
}

variable "function_name" {
  description = "Name of the Lambda function name"
  type        = string
}

variable "handler" {
  description = "The function entrypoint in your code."
  type        = string
}

variable "runtime" {
  description = "The identifier of the function's runtime."
  default     = "nodejs18.x"
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds."
  default     = 300
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime."
  default     = 128
}

variable "environment_variables" {
  description = "A map that defines environment variables for the Lambda Function."
  type        = map(string)
  default     = {}
}

variable "api_gateway_arn" {
  description = "arn for API gateway"
  type        = string
}

# API Gateway variables
variable "api_gateway_id" {
  description = "id for the API gateway you want to connect route to"
  type        = string
}

variable "integration_type" {
  description = "integration type"
  type        = string
  default     = "AWS_PROXY"
}

variable "payload_format_version" {
  description = "Specifies the payload format version. 2.0 is the version used for HTTP APIs."
  type        = string
  default     = "2.0"
}

variable "method_type" {
  description = "method type in all caps"
  type        = string
}

variable "route_path" {
  description = "route path"
  type        = string
}


