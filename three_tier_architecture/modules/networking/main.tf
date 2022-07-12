# ---- vpc/main.tf ---

# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "vpc"
  }
}

# Public subnet #1 - web-facing
resource "aws_subnet" "web_subnet" {
  count                   = var.item_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = var.availability_zone_names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${count.index}"
  }
}

# Public subnet #2 - app 
resource "aws_subnet" "app_subnet" {
  count                   = var.item_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.application_subnet_cidr[count.index]
  availability_zone       = var.availability_zone_names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "app-${count.index}"
  }
}

# Create Database Private Subnet
resource "aws_subnet" "db_subnet" {
  count             = var.item_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.database_subnet_cidr[count.index]
  availability_zone = var.availability_zone_names[count.index]

  tags = {
    Name = "database-${count.index}"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet_portal"
  }
}

# Nat gateway
resource "aws_nat_gateway" "ngw" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.web_subnet[1].id
}

# Create Web layer route table
resource "aws_route_table" "web_rt" {
  vpc_id = aws_vpc.vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "web_rt"
  }
}

# Web subnet route table association
resource "aws_route_table_association" "web_rt_association" {
  count          = var.item_count
  subnet_id      = aws_subnet.web_subnet[count.index].id
  route_table_id = aws_route_table.web_rt.id
}

# App subnet route table 
resource "aws_route_table" "app_rt" {
  vpc_id = aws_vpc.vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "app_rt"
  }
}

# App subnet route table association
resource "aws_route_table_association" "app_rt_association" {
  count          = var.item_count
  subnet_id      = aws_subnet.app_subnet[count.index].id
  route_table_id = aws_route_table.app_rt.id
}