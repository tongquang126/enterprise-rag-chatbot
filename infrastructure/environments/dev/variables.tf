variable "region" {
  description = "AWS region"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "personal"  
}


variable "bucket_name" {
  description = "Name of the internal documents S3 bucket"
  type        = string
}

variable "role_name" {
  description = "Name of the IAM role for Lambda function"
  type        = string
}