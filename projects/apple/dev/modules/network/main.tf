# Create VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}_${var.environment}_net"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Public subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}_${var.environment}_pub${count.index + 1}_net"
    Environment = var.environment
    Project     = var.project_name
    Tier        = "Public"
  }
}

# Private subnets (for applications)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  tags = {
    Name        = "${var.project_name}_${var.environment}_pvt${count.index + 1}_net"
    Environment = var.environment
    Project     = var.project_name
    Tier        = "Private"
  }
}

# RDS subnets
resource "aws_subnet" "rds" {
  count             = length(var.rds_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.rds_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  tags = {
    Name        = "${var.project_name}_${var.environment}_rds${count.index + 1}_net"
    Environment = var.environment
    Project     = var.project_name
    Tier        = "RDS"
  }
}
