# Elastic IPs for NAT Gateways
resource "aws_eip" "nat_eip" {
  count  = var.single_nat_gateway ? 1 : length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-nat-eip-${count.index + 1}"
    }
  )
}

# NAT Gateways
resource "aws_nat_gateway" "nat_gateway" {
  count         = var.single_nat_gateway ? 1 : length(var.public_subnet_cidrs)
  allocation_id = element(aws_eip.nat_eip[*].id, count.index)
  subnet_id     = element(aws_subnet.public_subnet[*].id, count.index)

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-nat-gw-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.internet_gateway]
}

# Private Route Tables
resource "aws_route_table" "private_route_table" {
  count  = var.single_nat_gateway ? 1 : length(var.private_app_subnet_cidrs)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gateway[*].id, var.single_nat_gateway ? 0 : count.index)
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-private-rt-${count.index + 1}"
    }
  )
}

# Private App Subnet Route Table Associations
resource "aws_route_table_association" "private_app_subnet_association" {
  count     = length(var.private_app_subnet_cidrs)
  subnet_id = element(aws_subnet.private_app_subnet[*].id, count.index)
  route_table_id = element(
    aws_route_table.private_route_table[*].id,
    var.single_nat_gateway ? 0 : count.index
  )
}

# Private Data Subnet Route Table Associations
resource "aws_route_table_association" "private_data_subnet_association" {
  count     = length(var.private_data_subnet_cidrs)
  subnet_id = element(aws_subnet.private_data_subnet[*].id, count.index)
  route_table_id = element(
    aws_route_table.private_route_table[*].id,
    var.single_nat_gateway ? 0 : count.index
  )
}
