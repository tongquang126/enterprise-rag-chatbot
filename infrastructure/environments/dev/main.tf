provider "aws" {
  region = var.region
  profile = var.aws_profile
}

# Step 1: Create the S3 bucket
module "s3_internal_docs" {
  source       = "../../modules/s3"
  bucket_name  = var.bucket_name
}

# Step 2: Create IAM Role for Lambda, passing in bucket ARN
module "lambda_iam_role" {
  source        = "../../modules/iam/lambda_access"
  role_name     = var.role_name
  s3_bucket_arn = module.s3_internal_docs.bucket_arn
}

# Step 3: Create bucket policy to allow Lambda role access
resource "aws_s3_bucket_policy" "lambda_access" {
  bucket = module.s3_internal_docs.bucket_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowLambdaAccess",
        Effect    = "Allow",
        Principal = {
          AWS = module.lambda_iam_role.role_arn
        },
        Action    = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource  = "${module.s3_internal_docs.bucket_arn}/*"
      }
    ]
  })
}
