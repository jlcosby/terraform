variable "aws_region" {
  default = "us-east-1"
}

variable "ami_id" {
  type = string
  default  = "ami-0cff7528ff583bf9a" # Amazon Linux 2, from AWS Console
}

variable "instance" {
  type    = string
  default = "t2.micro"
}

