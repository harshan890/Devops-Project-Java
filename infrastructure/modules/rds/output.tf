output "rds_endpoint" {
  value = aws_db_instance.java_app_db.endpoint
}

output "rds-security-group-id" {
  value = aws_security_group.rds_sg.id
}