output "api_endpoint" {
  value = aws_apigatewayv2_stage.default_stage.invoke_url
}

output "api_gateway_arn" {
  value = aws_apigatewayv2_api.http_api.arn
}

output "api_gateway_id" {
  value = aws_apigatewayv2_api.http_api.id
}
