resource "aws_iam_role" "lambda_access" {
  name = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = var.role_name
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  name = "${var.role_name}-s3-access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject"],
        Resource = "${var.s3_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.lambda_access.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}