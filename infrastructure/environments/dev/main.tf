provider "aws" {
  region = "us-east-1"
  profile = "personal"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.0"
    }    
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.0" 
    }
  }
  required_version = ">= 1.3.0"
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
  db_secret_arn = module.postgresql.db_secret_arn
}

module "postgresql" {
  source = "../../modules/postgresql"
  lambda_sg_id = module.lambda.lambda_sg_id
}
