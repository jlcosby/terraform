terraform   {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.19.0"
    }
  }
}

# Provider
provider "aws" {                       
        region = "us-east-1"
        access_key = "xxxxxxxxxxxxxxxxx"
        secret_key = "xxxxxxxxxxxxxxxxx"
}

# VPC
resource "aws_vpc" "vpc" {              
    cidr_block       = "10.0.0.0/16"
    tags = {
        Name = "vpc"
    }
}

# Two public subnets
resource "aws_subnet" "public_subnet1" { 
    tags = {
        Name = "public_subnet1"
        }
    vpc_id = aws_vpc.vpc.id 
    cidr_block = "10.0.1.0/24"           
    map_public_ip_on_launch = true       
    availability_zone = "us-east-1a"
}
 
resource "aws_subnet" "public_subnet2" { 
    tags = {
        Name = "public_subnet2"
        }
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.2.0/24"	         
    map_public_ip_on_launch = true       
    availability_zone = "us-east-1b"
}

# Two private subnets                   
resource "aws_subnet" "private_subnet1" { 		
    tags = {
        Name = "private_subnet1"
        }
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_subnet2" { 
    tags = {
        Name = "private_subnet2"
        }
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1b"
}

# Main routing table
resource "aws_route_table" "MainRT" {   
    tags = {
        Name = "MainRT"
        }
    vpc_id = aws_vpc.vpc.id
    route {
    cidr_block = "0.0.0.0/0"               
    gateway_id = aws_internet_gateway.ig.id
     }
}

# Main routing table association
resource "aws_route_table_association" "MainRTassociation1" {    
    subnet_id = aws_subnet.public_subnet1.id
    route_table_id = aws_route_table.MainRT.id
}

resource "aws_route_table_association" "MainRTassociation2" {    
    subnet_id = aws_subnet.public_subnet2.id
    route_table_id = aws_route_table.MainRT.id
}

# Internet Gateway
resource "aws_internet_gateway" "ig" {  
    tags = {
        Name = "ig"
    }
    vpc_id = aws_vpc.vpc.id
}

# Security group for app tier
resource "aws_security_group" "web_sg" {
    name = "app_sg"
    description = "allow web access to ec2 instances"
    vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance for public subnet 1
resource "aws_instance" "web_server1"   {             
	ami = "ami-0cff7528ff583bf9a"
	subnet_id = aws_subnet.public_subnet1.id
	instance_type = "t2.micro"
	security_groups = [aws_security_group.web_sg.id]

	user_data = <<-EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start
        systemctl enable 
        EOF
}

# EC2 instance for public subnet 2
resource "aws_instance" "web_server2" {             
	ami = "ami-0cff7528ff583bf9a"
	subnet_id = aws_subnet.public_subnet2.id
	instance_type = "t2.micro"
	security_groups = [aws_security_group.web_sg.id]
	
	user_data = <<-EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start
        systemctl enable 
        EOF
}

# Database subnet group
resource "aws_db_subnet_group" "db_subnet"  {
    name       = "db_subnet"
    subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
}

# Security group for database tier
resource "aws_security_group" "db_sg" {
    name = "db_sg"
    description = "allow traffic only from web_sg"
    vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id]
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Database instance in private subnet 1
resource "aws_db_instance" "db1" {
    allocated_storage    = 10
    engine               = "mysql"
    engine_version       = "5.7"
    instance_class       = "db.t3.micro"
    db_subnet_group_name = "db_subnet"
    vpc_security_group_ids = [aws_security_group.db_sg.id]
    username             = "admin"
    password             = "password"
    skip_final_snapshot  = true
}

# Application load balancer - Internet-facing
resource "aws_alb" "alb"    {
    name = "alb"
    load_balancer_type = "application"
    internal = false
    subnets         = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
    security_groups = [aws_security_group.web_sg.id]
}
