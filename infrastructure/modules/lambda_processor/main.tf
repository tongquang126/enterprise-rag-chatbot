
###############################
# Archive chỉ với handler.py
###############################
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/handler.py"
  output_path = "${path.module}/lambda.zip"
}

###############################
# IAM Role cho Lambda
###############################
resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

###############################
# Lambda Function
###############################
resource "aws_lambda_function" "this" {
  function_name = var.lambda_name
  handler       = "handler.handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_role.arn

  # tham chiếu đúng sang data.archive_file
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

###############################
# Cho phép S3 invoke Lambda
###############################
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}

###############################
# S3 Notification trigger Lambda
###############################
resource "aws_s3_bucket_notification" "s3_lambda_trigger" {
  bucket = var.bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]
}