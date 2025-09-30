terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.58"
    }
  }
}

provider "aws" {
  region = var.region
}

# VPC mínima
resource "aws_vpc" "db" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "soat-db-vpc" }
}

resource "aws_subnet" "db_a" {
  vpc_id                  = aws_vpc.db.id
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = false
  tags                    = { Name = "soat-db-subnet-a" }
}

resource "aws_subnet" "db_b" {
  vpc_id                  = aws_vpc.db.id
  cidr_block              = "10.20.2.0/24"
  map_public_ip_on_launch = false
  tags                    = { Name = "soat-db-subnet-b" }
}

resource "aws_db_subnet_group" "db" {
  name       = "soat-db-subnets"
  subnet_ids = [aws_subnet.db_a.id, aws_subnet.db_b.id]
}

resource "aws_security_group" "db" {
  name        = "soat-db-sg"
  description = "Allow Postgres"
  vpc_id      = aws_vpc.db.id

  ingress {
    description = "Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Em produção, restrinja!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "soat-db"
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "15.5"
  instance_class          = "db.t3.micro"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.db.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  deletion_protection     = false
  storage_encrypted       = true
  apply_immediately       = true
  backup_retention_period = 0
  tags                    = { Name = "soat-db" }
}
