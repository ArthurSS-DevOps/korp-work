resource "aws_vpc" "korp" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "korp-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.korp.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = {
    Name = "korp-public-subnet"
  }
}

resource "aws_internet_gateway" "korp" {
  vpc_id = aws_vpc.korp.id

  tags = {
    Name = "korp-internet-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.korp.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.korp.id
  }

  tags = {
    Name = "korp-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}