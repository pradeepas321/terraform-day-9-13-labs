variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "rds_subnet_cidrs" {
  description = "List of RDS subnet CIDRs"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}
