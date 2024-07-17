terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.52.0"
    }
  }
}

provider "aws" {
  region  = "us-west-2"
  profile = "default"
}

terraform {
  backend "s3" {
    bucket  = "esthetician-app-terraform-state-bucket"
    key     = "us-west-2/lambda/terraform.tfstate"
    region  = "us-west-2"
    profile = "default"
  }
}

data "terraform_remote_state" "api_gateway" {
  backend = "s3"

  config = {
    bucket = "esthetician-app-terraform-state-bucket"
    key    = "us-west-2/gateway/terraform.tfstate"
    region = "us-west-2"
  }

}

module "getClientCards" {
  source          = "../../modules/lambda/"
  function_name   = "getClientCards"
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "GET"
  route_path      = "/api/marketplace/client-search"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

module "getClientInfo" {
  source          = "../../modules/lambda/"
  function_name   = "getClientInfo"
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "GET"
  route_path      = "/api/client-info/{clientId}"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

module "login" {
  source          = "../../modules/lambda/"
  function_name   = "login"
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "POST"
  route_path      = "/api/user/login"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

module "addToWaitlist" {
  source          = "../../modules/lambda/"
  function_name   = "addToWaitlist"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "POST"
  route_path      = "/api/waitlist/add"

  environment_variables = {
    TABLE_NAME = "esthetician-app-waitlist"
    REGION     = "us-west-2"
  }
}
