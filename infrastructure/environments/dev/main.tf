provider "aws" {
  region = "us-east-1"
  profile = "personal"
}
terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.0" 
    }
  }
}

module "s3" {
  source = "../../modules/s3"
  bucket_name = "enterprise-internal-docs-dev"
}

module "lambda" {
  source = "../../modules/lambda_processor"
  lambda_name = "s3-trigger-lambda"
  bucket_name   = module.s3.bucket_name
  bucket_arn = module.s3.bucket_arn
}
