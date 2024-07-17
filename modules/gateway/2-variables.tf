variable "gateway_name" {
  description = "Name of api gateway"
  type        = string
  default     = "esthetician-app-backend-api-gateway"
}

variable "protocol" {
  description = "type of protocol"
  type        = string
  default     = "HTTP"
}

# Cors Configuration
variable "allow_credentials" {
  description = "Array of allowed headers"
  type        = bool
  default     = true
}

variable "allow_headers" {
  description = "Array of allowed headers"
  type        = set(string)
}

variable "allow_methods" {
  description = "Array of allowed headers"
  type        = set(string)
}

variable "allow_origins" {
  description = "Array of allowed headers"
  type        = set(string)
}

variable "expose_headers" {
  description = "Array of allowed headers"
  type        = set(string)
}

variable "max_age" {
  description = "Array of allowed headers"
  type        = number
  default     = 300
}

# variable "integration_type" {
#   description = "integration type"
#   type        = string
#   default     = "AWS_PROXY"
# }

# variable "integration_function_name" {
#   description = "The name of the lambda function"
#   type        = string
# }

# variable "integration_arn" {
#   description = "The arn of the Lambda function to be invoked by the API Gateway"
#   type        = string
# }

# variable "payload_format_version" {
#   description = "Specifies the payload format version. 2.0 is the version used for HTTP APIs."
#   type        = string
#   default     = "2.0"
# }

# variable "method_type" {
#   description = "method type in all caps"
#   type        = string
# }

# variable "route_path" {
#   description = "route path"
#   type        = string
# }

