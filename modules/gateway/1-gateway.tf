# Creates gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = var.gateway_name
  protocol_type = var.protocol

  cors_configuration {
    allow_credentials = var.allow_credentials
    allow_headers     = var.allow_headers
    allow_methods     = var.allow_methods
    allow_origins     = var.allow_origins
    expose_headers    = var.expose_headers
    max_age           = var.max_age
  }
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default" # Ensure this is correct
  auto_deploy = true
}
