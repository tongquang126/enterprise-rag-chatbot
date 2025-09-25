resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = var.cluster_identifier
  engine                  = "aurora-postgresql"
  engine_mode             = "serverless"
  engine_version          = var.engine_version
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.aurora_sg.id]

  scaling_configuration {
    auto_pause               = true
    max_capacity             = var.max_capacity
    min_capacity             = var.min_capacity
    seconds_until_auto_pause = var.seconds_until_auto_pause
  }

  storage_encrypted   = true
  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "Aurora DB Subnet Group"
  }
}

resource "aws_security_group" "aurora_sg" {
  name        = "aurora-db-sg"
  description = "Allow access to Aurora DB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow access from Lambda"  # MODIFIED: Updated description
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [var.lambda_security_group_id] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Aurora Security Group"
  }
}
