variable "lambda_name" {
  type = string
}

# variable "lambda_zip" {
#   type = string
# }

variable "bucket_name" {
  type = string
}

variable "bucket_arn" {                          
  type        = string
  description = "ARN of the S3 bucket"
}
