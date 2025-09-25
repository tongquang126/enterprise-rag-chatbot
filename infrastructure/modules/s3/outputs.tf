output "bucket_arn" {
  description = "The ARN of the S3 bucket" 
  value = aws_s3_bucket.internal_docs.arn
}
output "bucket_name" {
  description = "The bucket name"
  value = aws_s3_bucket.internal_docs.bucket
}