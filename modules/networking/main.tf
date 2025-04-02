# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-vpc"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-igw"
    }
  )
}

# Public Subnets
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-public-subnet-${element(var.azs, count.index)}"
    }
  )
}

# Private App Subnets
resource "aws_subnet" "private_app_subnet" {
  count                   = length(var.private_app_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_app_subnet_cidrs[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-private-app-subnet-${element(var.azs, count.index)}"
    }
  )
}

# Private Data Subnets
resource "aws_subnet" "private_data_subnet" {
  count                   = length(var.private_data_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_data_subnet_cidrs[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-private-data-subnet-${element(var.azs, count.index)}"
    }
  )
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-public-rt"
    }
  )
}

# Public Subnet Route Table Association
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

# Flow Logs (Optional but recommended for security)
resource "aws_flow_log" "vpc_flow_logs" {
  count                = var.enable_flow_logs ? 1 : 0
  log_destination      = aws_cloudwatch_log_group.flow_logs[0].arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc.id
  iam_role_arn         = aws_iam_role.flow_logs_role[0].arn

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${var.environment}-vpc-flow-logs"
    }
  )
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc-flow-logs/${var.app_name}-${var.environment}"
  retention_in_days = 30

  tags = var.common_tags
}

resource "aws_iam_role" "flow_logs_role" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${var.app_name}-${var.environment}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "flow_logs_policy" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${var.app_name}-${var.environment}-flow-logs-policy"
  role  = aws_iam_role.flow_logs_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
