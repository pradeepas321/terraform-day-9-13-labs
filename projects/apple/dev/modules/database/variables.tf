variable "db_subnet_ids" {
  description = "List of subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "db_sg_id" {
  description = "ID of the security group for RDS"
  type        = string
}

variable "project_name" {
  description = "Project name (e.g., apple)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev)"
  type        = string
}
