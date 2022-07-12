# --- ec2/main.tf ---

# Web security group 

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      =  var.vpc_id

  ingress {
    description = "HTTP from VPC"
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

  tags = {
    Name = "web_sg"
  }
}

# Web autoscaling template

resource "aws_launch_template" "web_launch_template" {
  name_prefix   = "web-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type
}  

# Web autoscaling group

resource "aws_autoscaling_group" "web_asg" {
  max_size           = 3
  min_size           = 1
  vpc_zone_identifier = var.public_subnet
  
  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = "$Latest"
  }
}

# App security group

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow inbound traffic from web tier"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic from web tier"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { 
    Name = "app-sg"
  }
}

# internal alb

resource "aws_lb" "app_app_lb" {
  name = "alb"
  internal = true
  load_balancer_type = "application"
  security_groups = [aws_security_group.app_sg.id]
  subnets = var.app_subnet
}

# alb listener

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target.arn
  }
}

# alb target group

resource "aws_lb_target_group" "app_target" {
  name     = "app-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    port     = 80
    protocol = "HTTP"
  }
}

# Autoscaling launch template

resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "app-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]
}

# App autoscaling group

resource "aws_autoscaling_group" "app_autoscaling" {
  max_size           = 4
  min_size           = 2
  target_group_arns = [aws_lb_target_group.app_target.arn]
  vpc_zone_identifier = var.public_subnet

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }
}