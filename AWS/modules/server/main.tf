terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "main" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [
    aws_security_group.main.id
  ]
  associate_public_ip_address = true
  user_data                   = templatefile("${path.module}/${var.init_script_path}", var.init_script_vars)
  user_data_replace_on_change = true

  tags = {
    Name = "${var.name}-server-${var.env}"
  }
}

data "aws_vpc" "main" {
  id = var.vpc_id
}


resource "aws_security_group" "main" {
  name        = "${var.name}-main-${var.env}"
  description = "Allow SSH, ${var.port_range} inbound traffic"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = var.port_range
    from_port   = var.port_range
    to_port     = var.port_range
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh_${var.port_range}-${var.env}"
  }
}
