resource "aws_vpc" "project_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "project_vpc"
  }
}
resource "aws_internet_gateway" "project_igw" {
  vpc_id = aws_vpc.project_vpc.id
  tags = {
    Name = "project_igw"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.project_vpc.id
  count             = length(var.private_subnets)
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.public_subnets)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "PublicRT" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "PublicRT"
  }
}

resource "aws_route" "PublicRT" {
  route_table_id         = aws_route_table.PublicRT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.project_igw.id
}

resource "aws_route_table_association" "PublicRTA" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.PublicRT.id
}

resource "docker_image" "centos" {
  name = "centos:latest"
}

resource "aws_ecr_repository" "aws-ecr" {
  name = "project_ecr"
  tags = {
    Name = "project_ecr"
  }
}

resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "project_cluster"
  tags = {
    Name = "project_ecs"
  }
}