output "db_secret_arn" {
  description = "ARN of the database secret in Secrets Manager"
  value       = aws_secretsmanager_secret.this.arn
}
