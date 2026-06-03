variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_sg_id" {
  description = "ID of the ECS security group"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the database secret in Secrets Manager"
  type        = string
}

variable "app_image" {
  description = "Docker image URI for the app (from ECR)"
  type        = string
}

variable "app_port" {
  description = "Port on which the app listens"
  type        = number
  default     = 8000
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "project_name" {
  description = "Project name (e.g., apple)"
  type        = string
  default     = "apple"
}

variable "environment" {
  description = "Environment name (e.g., dev)"
  type        = string
  default     = "dev"
}
