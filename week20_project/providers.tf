terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.17.0"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile                  = "terraform_user"
}

