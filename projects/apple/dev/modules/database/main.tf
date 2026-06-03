# Random password for the RDS database
resource "random_password" "this" {
  length           = 16
  special          = false
  override_special = "asdfgjhkqwrtopASHLSGSAGNAX12345667890" # Recommended in reference
}

# RDS subnet group
resource "aws_db_subnet_group" "this" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Subnet group for apple dev RDS instance"
  subnet_ids  = var.db_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-sg"
  }
}

# RDS instance
resource "aws_db_instance" "this" {
  identifier              = "${var.project_name}-${var.environment}-postgres"
  engine                  = "postgres"
  engine_version          = "15.15"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  db_name                 = "mydb"
  username                = "postgres"
  password                = random_password.this.result
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [var.db_sg_id]
  publicly_accessible     = false
  backup_retention_period = 0
  skip_final_snapshot     = true
  apply_immediately       = true

  tags = {
    Name = "${var.project_name}-${var.environment}-postgres"
  }
}

# AWS Secrets Manager secret
resource "aws_secretsmanager_secret" "this" {
  name = "${var.project_name}-${var.environment}-db-secret"

  tags = {
    Name = "${var.project_name}-${var.environment}-db-secret"
  }
}

# Secret version storing the full database connection string
resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    "username" : aws_db_instance.this.username,
    "password" : random_password.this.result,
    "host" : aws_db_instance.this.address,
    "port" : aws_db_instance.this.port,
    "dbname" : aws_db_instance.this.db_name,
    # Construct the full connection string in the format your app expects
    "db_link" : "postgresql://${aws_db_instance.this.username}:${random_password.this.result}@${aws_db_instance.this.address}:${aws_db_instance.this.port}/${aws_db_instance.this.db_name}"
  })
}
