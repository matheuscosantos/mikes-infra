provider "aws" {
  region = var.region
}

# -- bucket for terraform state

resource "aws_s3_bucket" "terraform_state_s3_bucket" {
  bucket = "${name}_terraform_state"
}

resource "aws_s3_bucket_acl" "terraform_state_s3_bucket_acl" {
  bucket = aws_s3_bucket.terraform_state_s3_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "terraform_state_s3_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state_s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# -- ecr

resource "aws_ecr_repository" "ecr_repository" {
  name = "${var.name}_repository"
}

# -- private network

resource "aws_vpc" "private_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.name}_private_vpc"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id     = aws_vpc.private_vpc.id
  cidr_block = "10.0.0.0/20"
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.name}_private_subnet_a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id     = aws_vpc.private_vpc.id
  cidr_block = "10.0.16.0/20"
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.name}_private_subnet_b"
  }
}

resource "aws_subnet" "private_subnet_c" {
  vpc_id     = aws_vpc.private_vpc.id
  cidr_block = "10.0.32.0/20"
  availability_zone = "${var.region}c"

  tags = {
    Name = "${var.name}_private_subnet_c"
  }
}

# -- ecs cluster

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name}_cluster"
}
