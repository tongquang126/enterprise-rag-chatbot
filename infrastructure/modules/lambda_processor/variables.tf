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

variable "private_subnet_ids" {
  type    = list(string)
  default = ["subnet-4d04b110", "subnet-f09be294", "subnet-4513a36a"]
  description = "Subnets for lambda and postgresql DB"
}

variable "vpc_id" {
  type    = string
  default = "vpc-f2bdff8a"
}

variable "db_secret_arn" {
  type = string
  description = "ARN of the Secret for postgresql DB"  
}