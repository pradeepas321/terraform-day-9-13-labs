# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Default route via IGW
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ------------------------------------------------------------------------------
# Private route table for ECS subnets (with internet access via NAT)
# ------------------------------------------------------------------------------
resource "aws_route_table" "private_ecs" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-ecs-rt"
    Environment = var.environment
    Project     = var.project_name
    Tier        = "ECS"
  }
}

# Default route via NAT Gateway for ECS subnets
resource "aws_route" "private_ecs_nat_access" {
  route_table_id         = aws_route_table.private_ecs.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

# Associate ECS private subnets with this route table
resource "aws_route_table_association" "private_ecs" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_ecs.id
}

# ------------------------------------------------------------------------------
# Private route table for RDS subnets (NO internet access – only local routes)
# ------------------------------------------------------------------------------
resource "aws_route_table" "private_rds" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-rds-rt"
    Environment = var.environment
    Project     = var.project_name
    Tier        = "RDS"
  }
}

# No default route added – RDS subnets will have only the VPC local route

# Associate RDS subnets with this route table
resource "aws_route_table_association" "private_rds" {
  count          = length(aws_subnet.rds)
  subnet_id      = aws_subnet.rds[count.index].id
  route_table_id = aws_route_table.private_rds.id
}
