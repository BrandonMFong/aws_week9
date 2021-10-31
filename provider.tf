# Author: Brando 

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.59.0"
    }
  }

  backend "s3" {
    bucket = "ece592-cloudtrail-brando"
    key    = "state.week9"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default" # From a ~/.aws/credentials file.
}

# VPC
resource "aws_vpc" "week9-vpc-v2" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "week9-vpc"
  }
}

# Subnets 

# Subnet 1
resource "aws_subnet" "week9-sub-a-v2" {
  vpc_id                  = aws_vpc.week9-vpc-v2.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "week9-sub-a"
  }
}

# Subnet 2
resource "aws_subnet" "week9-sub-b-v2" {
  vpc_id                  = aws_vpc.week9-vpc-v2.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "week9-sub-b"
  }
}

# Internet Gate Way 
resource "aws_internet_gateway" "week9-igw-v2" {
  vpc_id = aws_vpc.week9-vpc-v2.id

  tags = {
    Name = "week9-igw"
  }
}

# Route Table
resource "aws_route_table" "week9-rt-v2" {
  vpc_id = aws_vpc.week9-vpc-v2.id

  route = [{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.week9-igw-v2.id

    # Values suggested by professor
    egress_only_gateway_id    = ""
    instance_id               = ""
    ipv6_cidr_block           = ""
    nat_gateway_id            = ""
    network_interface_id      = ""
    transit_gateway_id        = ""
    vpc_endpoint_id           = ""
    vpc_peering_connection_id = ""

    # Values suggested by the validate process
    # Investigate these values if there is an issue
    # with our config 
    carrier_gateway_id         = ""
    destination_prefix_list_id = ""
    local_gateway_id           = ""
  }, ]

  tags = {
    Name = "week9-rt"
  }
}

# Security Group
resource "aws_security_group" "week9-ssh-sg-v2" {
  name        = "week9_ssh_sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.week9-vpc-v2.id

  ingress = [{
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    # Suggested by professor
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]

  egress = [{
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    # Suggested
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]

  tags = {
    Name = "week9-ssh-sg"
  }
}

# EC2
resource "aws_instance" "week9-vm-v2" {
  ami                  = "ami-02e136e904f3da870"
  instance_type        = "t2.micro"
  subnet_id            = aws_subnet.week9-sub-a-v2.id
  iam_instance_profile = aws_iam_instance_profile.week9_iam_profile.name

  vpc_security_group_ids = [
    aws_security_group.week9-ssh-sg-v2.id
  ]

  key_name = "ECE592"

  tags = {
    Name = "week9-vm"
  }
}

# IAM profile ref
resource "aws_iam_instance_profile" "week9_iam_profile" {
  name = "week9_iam_profile"
  role = aws_iam_role.automation-role-v3.name
  tags = {}
}
