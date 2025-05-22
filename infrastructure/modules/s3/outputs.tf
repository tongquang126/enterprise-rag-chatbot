output "bucket_name" {
  value = aws_s3_bucket.internal_docs.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.internal_docs.arn
}