output "role_arn" {
  description = "ARN of the IAM Role for Lambda"
  value       = aws_iam_role.lambda_access.arn
}