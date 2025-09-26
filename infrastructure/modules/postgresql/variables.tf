variable "vpc_id" {
  type    = string
  default = "vpc-f2bdff8a"
}

variable "private_subnet_ids" {
  type    = list(string)
  default = ["subnet-4d04b110", "subnet-f09be294", "subnet-4513a36a"]
  description = "Subnets for RDS"
}

variable "allowed_cidr_blocks" {
  type = list(string)
  default = ["10.0.0.0/16"] # Subnet for Dev server to test
}
variable "db_engine_version" {
  default = "15.3" # PostgreSQL 15
}
variable "db_instance_class" {
  default = "db.t3.micro"
}
variable "db_allocated_storage" {
  default = 20
}
variable "db_username" {
  default = "ragadmin"
}
variable "db_name" {
  default = "ragdb_main"
}

variable "lambda_sg_id" {
  type = string
  description = "Security Group ID of Lambda that can access RDS"
  default = null
}