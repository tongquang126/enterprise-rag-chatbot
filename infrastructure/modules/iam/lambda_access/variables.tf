variable "role_name" {
  description = "Name of the IAM role for Lambda"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket Lambda needs to access"
  type        = string
}