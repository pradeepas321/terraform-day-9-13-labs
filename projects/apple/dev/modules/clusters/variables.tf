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
variable "autoscaling" {
  description = "Auto Scaling settings for the ECS service"
  type = object({
    min_capacity       = number
    max_capacity       = number
    cpu_target_value   = number
    scale_in_cooldown  = number
    scale_out_cooldown = number
  })
  default = {
    min_capacity       = 1
    max_capacity       = 4
    cpu_target_value   = 60
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
