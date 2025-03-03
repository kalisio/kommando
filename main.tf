terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
}

# Security Group to authorize SSH
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_ssh"
  }
}

# EC2 instance
resource "aws_instance" "ubuntu_load_testing" {
  ami           = "ami-064736ff8301af3ee" # available only in eu-west-3 region
  instance_type = var.instance_type
  key_name      = "load_testing_keypair" 
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  
  user_data = templatefile("setup.sh", {
    DOCKER_IMAGE           = var.docker_image
    COMMAND                = var.command
    DEVELOPMENT_REPO_URL   = var.development_repo_url
    RCLONE_CONFIG_REPO_URL = var.rclone_config_repo_url
    SOPS_AGE_KEY           = var.sops_age_key
    TARGET                 = var.target
    ENVIRONMENT            = var.environment
    ADMIN_JWT_ACCESS_TOKEN = var.admin_jwt_access_token
    LOW_DURATION           = var.low_duration
    LOW_ARRIVAL_RATE       = var.low_arrival_rate
    LOW_MAX_VUSERS         = var.low_max_vusers
    MEDIUM_DURATION        = var.medium_duration
    MEDIUM_ARRIVAL_RATE    = var.medium_arrival_rate
    MEDIUM_MAX_VUSERS      = var.medium_max_vusers
    HIGH_DURATION          = var.high_duration
    HIGH_ARRIVAL_RATE      = var.high_arrival_rate
    HIGH_MAX_VUSERS        = var.high_max_vusers
  })

  tags =  {
    Name = "ubuntu-load-testing"
  }
}

# Output to obtain the public IP
output "instance_ip" {
  value = aws_instance.ubuntu_load_testing.public_ip
}