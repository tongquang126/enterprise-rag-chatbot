terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.17.0"
    }
  }
}

# ===============================
# Random password
# ===============================
resource "random_password" "db_password" {
  length  = 16
  special = true
}


# ===============================
# VPC Security Group for RDS
# ===============================
resource "aws_security_group" "db_sg" {
  name        = "ragdb-sg"
  description = "Allow PostgreSQL access"
  vpc_id      = var.vpc_id # define in variables

# Fixed ingress for dev server to connect to test
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks # define allowed CIDRs
  }

  # Rule cho Lambda SG (chỉ khi có giá trị)
  dynamic "ingress" {
    for_each = var.lambda_sg_id != null ? [var.lambda_sg_id] : []
    content {
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ===============================
# DB Subnet Group
# ===============================
resource "aws_db_subnet_group" "db_subnet" {
  name       = "ragdb-subnet"
  subnet_ids = var.private_subnet_ids # list of subnet IDs
  tags = {
    Name = "RAGDB Subnet"
  }
}

# ===============================
# PostgreSQL RDS Instance
# ===============================
resource "aws_db_instance" "ragdb" {
  identifier              = "ragdb-instance"
  engine                  = "postgres"
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  username                = var.db_username
  password                = random_password.db_password.result
  db_subnet_group_name    = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  publicly_accessible     = false
  skip_final_snapshot     = true
  apply_immediately       = true
  deletion_protection     = false
  backup_retention_period = 7
  multi_az                = false

  tags = {
    Name = "RAGDB"
  }
}

# ===============================
# PostgreSQL Provider (connects to RDS)
# ===============================
provider "postgresql" {
  host     = aws_db_instance.ragdb.address
  port     = aws_db_instance.ragdb.port
  username = aws_db_instance.ragdb.username
  password = random_password.db_password.result
  sslmode  = "require"
}

# ===============================
# Create Database inside RDS
# ===============================
resource "postgresql_database" "ragdb_main" {
  name = var.db_name
}

# Lưu secret vào AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_secret" {
  name = "ragdb-credentials"
}

resource "aws_secretsmanager_secret_version" "db_secret_value" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    host     = aws_db_instance.ragdb.address
    port     = aws_db_instance.ragdb.port
    dbname   = var.db_name
  })
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db_secret.arn
}