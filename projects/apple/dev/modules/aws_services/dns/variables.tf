variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "Canonical hosted zone ID of the ALB"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the ALB (to attach HTTPS listener)"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
}

variable "project_name" {
  description = "Project name (for tagging)"
  type        = string
  default     = "apple"
}

variable "environment" {
  description = "Environment name (for tagging)"
  type        = string
  default     = "dev"
}
