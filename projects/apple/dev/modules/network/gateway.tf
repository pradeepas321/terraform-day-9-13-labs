# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ------------------------------------------------------------------------------
# NAT Gateway resources 
# - Elastic IP
# - NAT Gateway
# ------------------------------------------------------------------------------
# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-eip"
    Environment = var.environment
    Project     = var.project_name
  }
}

# NAT Gateway – placed in the first public subnet (index 0)
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id   # first public subnet (ap-south-1a)

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat"
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [aws_internet_gateway.this]
}
