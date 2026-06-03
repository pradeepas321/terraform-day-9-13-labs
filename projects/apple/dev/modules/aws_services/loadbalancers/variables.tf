variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "ID of the ALB security group"
  type        = string
}

variable "app_port" {
  description = "Port on which the app listens"
  type        = number
  default     = 8000
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

variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS (optional, if not provided, HTTPS listener is not created)"
  type        = string
  default     = null
}
