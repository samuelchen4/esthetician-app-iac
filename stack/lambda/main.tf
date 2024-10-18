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

# DESC: grabs user information for a clerk_user_id
# Route: /api/clerk-users/:clerkUserId
# Method: GET
module "getUserByClerkId" {
  source          = "../../modules/lambda/"
  function_name   = "getUserByClerkId"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "GET"
  route_path      = "/api/clerk-users/{clerkUserId}"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

# DESC: posts user for a new clerk_user_id
# Route: /api/clerk-users/:clerkUserId
# Method: POST
module "postUserByClerkId" {
  source          = "../../modules/lambda/"
  function_name   = "postUserByClerkId"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "POST"
  route_path      = "/api/clerk-users/{clerkUserId}"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}


# DESC: posts user for a new clerk_user_id
# Route: /api/clerk-users/:clerkUserId
# Method: POST
module "patchRoleById" {
  source          = "../../modules/lambda/"
  function_name   = "patchRoleById"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "PATCH"
  route_path      = "/api/users/{userId}/roles"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

# DESC: Patch first and last name for user by _id
# Route: /api/users/:userId/names
# Method: PATCH
module "patchBasicUserInfoById" {
  source          = "../../modules/lambda/"
  function_name   = "patchBasicUserInfoById"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "PATCH"
  route_path      = "/api/users/{userId}/basic"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

# DESC: Patch first and last name for user by _id
# Route: /api/users/:userId/names
# Method: PATCH
module "patchNameById" {
  source          = "../../modules/lambda/"
  function_name   = "patchNameById"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "PATCH"
  route_path      = "/api/users/{userId}/names"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

# DESC: Patch email for user by _id
# Route: /api/users/:userId/emails
# Method: PATCH
module "patchEmailById" {
  source          = "../../modules/lambda/"
  function_name   = "patchEmailById"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "PATCH"
  route_path      = "/api/users/{userId}/emails"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

# DESC: Patch phone for user by _id
# Route: /api/users/:userId/phones
# Method: PATCH
module "patchPhoneById" {
  source          = "../../modules/lambda/"
  function_name   = "patchPhoneById"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "PATCH"
  route_path      = "/api/users/{userId}/phones"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

# DESC: Patch address for user by _id
# Route: /api/users/:userId/address
# Method: PATCH
module "patchAddressById" {
  source          = "../../modules/lambda/"
  function_name   = "patchAddressById"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "PATCH"
  route_path      = "/api/users/{userId}/address"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}
# DESC: posts user for a new clerk_user_id
# Route: /api/clerk-users/:clerkUserId
# Method: POST
module "postClientInfoById" {
  source          = "../../modules/lambda/"
  function_name   = "postClientInfo"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "POST"
  route_path      = "/api/users/{userId}/clients"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

# DELETE getClientCards source code

# getUserInfoById
# DESC: Gets all fields from users table based on _id
# Route: /api/users
# Method: GET
module "getUserInfoById" {
  source          = "../../modules/lambda/"
  function_name   = "getUserInfoById"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "GET"
  route_path      = "/api/users/{userId}"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}
# getSchedulesById
# DESC: Gets all fields for all records from user_schedules table based on user_id
# Route: /api/users/:userId/schedules
# Method: GET
module "getSchedulesByUserId" {
  source          = "../../modules/lambda/"
  function_name   = "getSchedulesByUserId"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "GET"
  route_path      = "/api/users/{userId}/schedules"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}
# getPhotosById
# DESC: Gets all fields for all records from photos table based on user_id
# Route: /api/users/:userId/photos
# Method: GET
module "getPhotosByUserId" {
  source          = "../../modules/lambda/"
  function_name   = "getPhotosByUserId"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "GET"
  route_path      = "/api/users/{userId}/photos"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}
# getServicesById
# DESC: Gets all fields for all records from user_services table based on user_id
# Route: /api/users/:userId/services
# Method: GET
module "getServicesByUserId" {
  source          = "../../modules/lambda/"
  function_name   = "getServicesByUserId"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "GET"
  route_path      = "/api/users/{userId}/services"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

# addServicesById
# DESC: POSTS services for a user_id
# Route: /api/users/:userId/services
# Method: POST
module "addServicesById" {
  source          = "../../modules/lambda/"
  function_name   = "addServicesById"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "POST"
  route_path      = "/api/users/{userId}/services"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

# generatePresignedUrls
# DESC: generates presigned urls for S3
# Route: /api/users/:userId/photos/presigned-urls
# Method: POST
module "generatePresignedUrls" {
  source          = "../../modules/lambda/"
  function_name   = "generatePresignedUrls"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "POST"
  route_path      = "/api/users/{userId}/photos/presigned-urls"

  environment_variables = {
    REGION      = "us-west-2"
    BUCKET_NAME = "beauty-connect-user-portfolio-photos"
  }
}

# generatePresignedUrls
# DESC: generates presigned urls for S3
# Route: /api/users/:userId/photos/presigned-urls
# Method: POST
module "getPhotoByPresignedUrl" {
  source          = "../../modules/lambda/"
  function_name   = "getPhotoByPresignedUrl"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "GET"
  route_path      = "/api/photos/keys"

  environment_variables = {
    REGION      = "us-west-2"
    BUCKET_NAME = "beauty-connect-user-portfolio-photos"
  }
}

# addPhotosById
# DESC: POSTS photos for a user_id
# Route: /api/users/:userId/photos
# Method: POST
module "addPhotosById" {
  source          = "../../modules/lambda/"
  function_name   = "addPhotosById"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "POST"
  route_path      = "/api/users/{userId}/photos"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

# addSchedulesById
# DESC: POSTS schedules for a user_id
# Route: /api/users/:userId/schedules
# Method: POST
module "addSchedulesById" {
  source          = "../../modules/lambda/"
  function_name   = "addSchedulesById"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "POST"
  route_path      = "/api/users/{userId}/schedules"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

# getAetheticians
# DESC: Gets aetheticians based on service
# Route: /api/aetheticians
# Method: GET
module "getAetheticians" {
  source          = "../../modules/lambda/"
  function_name   = "getAetheticians"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "GET"
  route_path      = "/api/aetheticians"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}


# getTrendingAetheticians
# DESC: Gets aetheticians based on service
# Route: /api/aetheticians/trending
# Method: GET
module "getTrendingAetheticians" {
  source          = "../../modules/lambda/"
  function_name   = "getTrendingAetheticians"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "GET"
  route_path      = "/api/aetheticians/trending"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

# getClosestAetheticians
# DESC: Gets aetheticians based on service
# Route: /api/aetheticians/trending
# Method: GET
module "getClosestAetheticians" {
  source          = "../../modules/lambda/"
  function_name   = "getClosestAetheticians"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "GET"
  route_path      = "/api/aetheticians/nearby"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

# postLike
# DESC: posts a like for a user
# Route: /api/likes
# Method: POST
module "postLike" {
  source          = "../../modules/lambda/"
  function_name   = "postLike"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "POST"
  route_path      = "/api/likes"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

# deleteLike
# DESC: deletes a like for a user
# Route: /api/likes
# Method: DELETE
module "deleteLike" {
  source          = "../../modules/lambda/"
  function_name   = "deleteLike"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "DELETE"
  route_path      = "/api/likes"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}

# getLikes
# DESC: gets all likes for a user
# Route: /api/likes
# Method: GET
module "getLikes" {
  source          = "../../modules/lambda/"
  function_name   = "getLikes"
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  timeout         = 300
  memory_size     = 128
  api_gateway_arn = data.terraform_remote_state.api_gateway.outputs.api_gateway_arn
  api_gateway_id  = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  method_type     = "GET"
  route_path      = "/api/likes"

  environment_variables = {
    DB_USER     = "postgres"
    DB_PASSWORD = "!Qu5k3G0Z$})~Z##XzYaUROyOXk]"
    DB_HOST     = "esthetician-app-db.cvlzcxvilm37.us-west-2.rds.amazonaws.com"
    DB_PORT     = 5432
    DB_DATABASE = "postgres"
  }
}


