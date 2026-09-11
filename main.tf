terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.64.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region

  assume_role {
    role_arn     = var.terraform_execution_role_arn
    session_name = "terraform"
  }
}

resource "aws_vpc" "security_lab" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "SecurityLab-VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.security_lab.id
  cidr_block = var.public_subnet_cidr

  tags = {
    Name = "SecurityLab-Public Subnet"
  }
}

resource "aws_internet_gateway" "lab_gateway" {
  vpc_id = aws_vpc.security_lab.id

  tags = {
    Name = "SecurityLab-Internet Gateway"
  }
}

resource "aws_route_table" "lab_public_route_table" {
  vpc_id = aws_vpc.security_lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_gateway.id
  }

  tags = {
    Name = "Default Public Route"
  }
}

resource "aws_route_table_association" "public_route_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.lab_public_route_table.id
}

resource "aws_security_group" "lab_security_group" {
  name        = "lab_security_group"
  description = "Security group for SecurityLab resources"
  vpc_id      = aws_vpc.security_lab.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.lab_security_group.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.security_lab.id
  cidr_block = var.private_subnet_cidr

  tags = {
    Name = "SecurityLab-Private Subnet"
  }
}

resource "aws_route_table" "lab_private_route_table" {
  vpc_id = aws_vpc.security_lab.id

  tags = {
    Name = "SecurityLab-Private Route"
  }
}

resource "aws_route_table_association" "private_route_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.lab_private_route_table.id
}

resource "aws_iam_role" "ec2_role" {
  name = "lab-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "lab-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "lab_server_1" {
  ami                         = "ami-02167eae61967e403"
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.lab_security_group.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "SecurityLab-Server-1"
  }
}