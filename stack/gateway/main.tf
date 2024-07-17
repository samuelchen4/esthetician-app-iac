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
    key     = "us-west-2/gateway/terraform.tfstate"
    region  = "us-west-2"
    profile = "default"
  }
}

# Method: GET
# DESC: gets client cards in marketplace
module "api_gateway" {
  source         = "../../modules/gateway"
  allow_headers  = ["*"]
  allow_methods  = ["*"]
  allow_origins  = ["https://main.d3jm5wfa9rhc6f.amplifyapp.com", "http://localhost:3000", "https://main.d28sxseyh583wn.amplifyapp.com", "http://localhost:4321", "https://beautyconnection.ca", "https://lander.beautyconnection.ca"]
  expose_headers = ["*"]
}
