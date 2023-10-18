terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region  = "ap-south-1"
  access_key = "AKIA4F3SO4IFSDLCBA6D"
  secret_key = "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"
  #profile = "dev"
}
resource "aws_vpc" "urotaxivpc" {
  cidr_block = var.urotaxi_cidr
  tags = {
    Name = "urotaxivpc"
  }
}

resource "aws_subnet" "urotaxi_pubsn1" {
  vpc_id            = aws_vpc.urotaxivpc.id
  cidr_block        = var.urotaxi_pubsn1_cidr
  availability_zone = "ap-south-1a"
  tags = {
    Name = "urotaxi_pubsn1"
  }
}

resource "aws_subnet" "urotaxi_prvsn3" {
  vpc_id            = aws_vpc.urotaxivpc.id
  cidr_block        = var.urotaxi_prvsn3_cidr
  availability_zone = "ap-south-1a"
  tags = {
    Name = "urotaxi_prvsn3"
  }
}
resource "aws_subnet" "urotaxi_prvsn4" {
  vpc_id            = aws_vpc.urotaxivpc.id
  cidr_block        = var.urotaxi_prvsn4_cidr
  availability_zone = "ap-south-1b"
  tags = {
    Name = "urotaxi_prvsn4"
  }
}

resource "aws_internet_gateway" "urotaxiig" {
  vpc_id = aws_vpc.urotaxivpc.id
  tags = {
    Name = "urotaxiig"
  }
}

resource "aws_route_table" "urotaxirt" {
  vpc_id = aws_vpc.urotaxivpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.urotaxiig.id
  }
  tags = {
    Name = "urotaxirt"
  }
}

resource "aws_route_table_association" "urotaxiigrtassociation" {
  route_table_id = aws_route_table.urotaxirt.id
  subnet_id      = aws_subnet.urotaxi_pubsn1.id
}

resource "aws_security_group" "urotaxijavaserversg" {
  vpc_id = aws_vpc.urotaxivpc.id
  ingress {
    from_port   = "8080"
    to_port     = "8080"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "urotaxijavaserversg"
  }
}
resource "aws_security_group" "urotaxidbsg" {
  vpc_id = aws_vpc.urotaxivpc.id
  ingress {
    from_port   = "3306"
    to_port     = "3306"
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "urotaxidbsg"
  }
}

resource "aws_db_subnet_group" "urotaxidbsngrp" {
  name       = "urotaxidbsngrp"
  subnet_ids = [aws_subnet.urotaxi_prvsn3.id, aws_subnet.urotaxi_prvsn4.id]
  tags = {
    Name = "urotaxidbsngrp"
  }
}

resource "aws_db_instance" "urotaxidbec2" {
  vpc_security_group_ids = [aws_security_group.urotaxidbsg.id]
  allocated_storage      = 10
  db_name                = "urotaxidb"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.urotaxi_db_instance_type
  username               = var.urotaxi_db_username
  password               = var.urotaxi_db_password
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.urotaxidbsngrp.id
}

resource "aws_key_pair" "urotaxi_kp" {
  public_key = var.urotaxi_public_key
  key_name   = "urotaxikpname"
}

resource "aws_instance" "urotaxiec2" {
  security_groups             = [aws_security_group.urotaxijavaserversg.id]
  key_name                    = aws_key_pair.urotaxi_kp.key_name
  subnet_id                   = aws_subnet.urotaxi_pubsn1.id
  ami                         = var.ami
  instance_type               = var.instance_shape
  associate_public_ip_address = true

}





















