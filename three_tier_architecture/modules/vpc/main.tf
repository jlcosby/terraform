# ---- vpc/main.tf ---

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