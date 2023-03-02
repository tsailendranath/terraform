terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = "default"
  region = "ap-south-1"
}

resource "aws_vpc" "sailorvpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      "Name" = "sailorvpc"
    }
}

resource "aws_subnet" "sailorpubsn" {
    vpc_id = aws_vpc.sailorvpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
    tags = {
      "Name" = "sailorpubsn"
    }
}

resource "aws_internet_gateway" "sailorig" {
  vpc_id = aws_vpc.sailorvpc.id
  tags = {
    "Name" = "sailorig"
  }
}

resource "aws_route_table" "sailorigrt" {
  vpc_id = aws_vpc.sailorvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sailorig.id
  }
}

resource "aws_route_table_association" "sailorigrtassociation" {
  route_table_id = aws_route_table.sailorigrt.id
  subnet_id = aws_subnet.sailorpubsn.id
}

resource "aws_security_group" "sailorpubsg" {
    vpc_id = aws_vpc.sailorvpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_key_pair" "sailorkp" {
  key_name = "sailorkp"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpHxMihFyyZ7Ih79udR42MhJzWxD/4+RPj09vSt152ruAHJmMCmBeAo1Jm/vCg7Os44SxRpFaj/gW0Fbo+BolxI4DYKrA6uIB8Uh7jJsmfvbbc4bE31qsEvu7RmeMbbJikxxnWdJR+pg0y54dUGnyOe/JKK2bhUN0rc925y4KjC0AhO35n61rQQAQ96Vsu6FRqoV07rA0lRk2XpV0kIilVaIqlo770/q3+Bm1n9Cpv2KFNQJ0/UNxNv19gUpnFTdo3cF8KKT4VB9lyA2kjue3COQvKUUifcvMjRBurFuWsD0Y/efngcHxpFZ+AbIymacuudBnyGVKgbAqDarwpQYSWySkBk9x1evPH/N+P9bYfDP13pMcBxtmfgV9bSZLoigTjqWM8P8ICXJdJ8RGIwmOLHT5zR5q+QeeLT+0SCpR1bXygY+K5TTeJmhJN0JUWVBi4TcnrbIzueNSdGFEM03/7nJelIG4I3g2QkYJ5GEXnEqg2znVUXBvzySxBA7NxmdM= Sriman@DESKTOP-1QI4S5N"
}

resource "aws_instance" "sailorec2" {
  subnet_id = aws_subnet.sailorpubsn.id
  vpc_security_group_ids = [aws_security_group.sailorpubsg.id]
  instance_type = "t2.micro"
  ami = "ami-024c319d5d14b463e"
  key_name = aws_key_pair.sailorkp.key_name
  associate_public_ip_address = true
  tags = {
    "Name" = "sailorec2"
  }
}














