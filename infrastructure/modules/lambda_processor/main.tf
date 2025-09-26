
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
  vpc_config {
    subnet_ids         = var.private_subnet_ids   # private subnets dùng chung với RDS
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}
###############################
# Security Group for Lambda
###############################
resource "aws_security_group" "lambda_sg" {
  name        = "${var.lambda_name}-sg"
  description = "Allow Lambda to access RDS"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Only connect to outside 
  }

  tags = {
    Name = "${var.lambda_name}-sg"
  }
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

###############################
# Allow Lambda to read Secrets Manager
# Use inline IAM policy only allow Lambda read specific Secret
###############################
resource "aws_iam_policy" "lambda_secret_policy" {
  name        = "${var.lambda_name}-secret-policy"
  description = "Allow Lambda to read RDS secret"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Effect   = "Allow",
        Resource = var.db_secret_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_secret_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_secret_policy.arn
}

output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}
