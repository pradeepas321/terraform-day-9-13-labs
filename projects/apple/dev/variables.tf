variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "apple"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "172.12.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["172.12.1.0/24", "172.12.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["172.12.3.0/24", "172.12.4.0/24"]
}

variable "rds_subnet_cidrs" {
  description = "RDS subnet CIDRs"
  type        = list(string)
  default     = ["172.12.5.0/24", "172.12.6.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}
variable "app_image" {
  description = "Docker image URI for the app (from ECR)"
  type        = string
  default     = "963462797840.dkr.ecr.ap-south-1.amazonaws.com/student-portal:1.0"
}
