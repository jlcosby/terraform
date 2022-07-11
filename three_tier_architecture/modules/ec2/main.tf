# --- ec2/main.tf ---

# Application load balancer - Internet-facing
resource "aws_alb" "alb"    {
    name = "alb"
    load_balancer_type = "application"
    internal = false
    subnets         = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
    security_groups = [aws_security_group.web_sg.id]
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
    cidr_blocks = ["0.0.0.0/0"]
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