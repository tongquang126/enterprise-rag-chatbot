output "db_cluster_endpoint" {
  description = "The writer endpoint of the Aurora cluster"
  value = aws_rds_cluster.aurora.endpoint
}

output "db_cluster_identifier" {
  description = "Identifier for the Aurora DB cluster"
  value = aws_rds_cluster.aurora.cluster_identifier
}

output "db_subnet_group" {
  description = "Aurora DB subnet group name"
  value = aws_db_subnet_group.aurora_subnet_group.name
}

output "aurora_security_group_id" {
  description = "Security group ID used by Aurora"
  value = aws_security_group.aurora_sg.id
}