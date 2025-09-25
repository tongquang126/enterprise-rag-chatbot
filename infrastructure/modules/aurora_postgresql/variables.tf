variable "cluster_identifier" {
  description = "Aurora cluster identifier"
  type        = string
}

variable "engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  # default     = "13.6"
}

variable "master_username" {
  description = "Master DB username"
  type        = string
  sensitive   = true
}

variable "master_password" {
  description = "Master DB password"
  type        = string
  sensitive   = true
}

variable "backup_retention_period" {
  type    = number
  # default = 1
}

variable "preferred_backup_window" {
  type    = string
  # default = "07:00-09:00"
}

variable "min_capacity" {
  type    = number
  # default = 1
}

variable "max_capacity" {
  type    = number
  # default = 2
}

variable "seconds_until_auto_pause" {
  type    = number
  # default = 300
}

variable "subnet_ids" {
  description = "Subnets for DB subnet group"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "lambda_security_group_id" {
  description = "ID of Lambda SG allowed to access Aurora"
  type        = string
}
