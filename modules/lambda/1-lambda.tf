# Retrieve the current AWS region
data "aws_region" "current" {}

data "archive_file" "main" {
  type        = "zip"
  source_dir  = "${path.module}/code/${var.function_name}"
  output_path = "${path.module}/zip/${var.function_name}.zip"
}

# data "aws_iam_role" "lambda_execution_role" {
#   name = "lambda-execution-role"
#   arn  = "arn:aws:iam::283466803266:role/lambda-execution-role"
# }

# data "aws_iam_policy" "lambda_policy" {
#   name = "lambda_policy"
# }

resource "aws_lambda_function" "main" {
  function_name = var.function_name
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size
  handler       = var.handler

  filename = "${path.module}/zip/${var.function_name}.zip"

  source_code_hash = data.archive_file.main.output_base64sha256

  tags = {
    project = var.project
    Name    = "${var.project}-${var.function_name}"
  }

  role = "arn:aws:iam::283466803266:role/lambda-execution-role"

  dynamic "environment" {
    for_each = length(keys(var.environment_variables)) == 0 ? [] : [true]
    content {
      variables = var.environment_variables
    }
  }
}

# IAM Role for Lambda Function
# resource "aws_iam_role" "lambda_execution_role" {
#   count = length(data.aws_iam_role.lambda_execution_role.name) > 0 ? 0 : 1

#   name = "lambda-execution-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action = "sts:AssumeRole",
#       Effect = "Allow",
#       Principal = {
#         Service = "lambda.amazonaws.com"
#       }
#     }]
#   })
# }

# # IAM Policy for Lambda Function to Allow API Gateway Invocation and Logs
# resource "aws_iam_policy" "lambda_policy" {
#   count = length(data.aws_iam_role.lambda_execution_role.name) > 0 ? 0 : 1

#   name        = "lambda_policy"
#   description = "Policy for Lambda to be invoked by API Gateway and write logs"
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ],
#         Effect   = "Allow",
#         Resource = "arn:aws:logs:*:*:*"
#       },
#       {
#         Action = [
#           "lambda:InvokeFunction"
#         ],
#         Effect   = "Allow",
#         Resource = "*"
#       }
#     ]
#   })
# }

# Attaches to gateway
# Attach Policy to Role
# resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
#   role       = aws_iam_role.lambda_execution_role.name
#   policy_arn = aws_iam_policy.lambda_policy.arn
# }

# replicate this for multiple lambdas
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = var.api_gateway_id
  integration_type       = var.integration_type
  integration_uri        = aws_lambda_function.main.arn
  payload_format_version = var.payload_format_version
}

# Add Resource-based Policy to Lambda for API Gateway Invocation
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${var.account_id}:${var.api_gateway_id}/*/*"
}

# Attaches a route to the lambda
resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = var.api_gateway_id
  route_key = "${var.method_type} ${var.route_path}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

