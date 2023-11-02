provider "aws" {
  region = var.region
}

# -- ecr

resource "aws_ecr_repository" "ecr_repository" {
  name = "${var.name}_app"
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

# -- creating capacity provider

data "aws_ami" "amazon_linux_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_launch_template" "ec2_launch_configuration" {
  image_id      = data.aws_ami.amazon_linux_ami.id
  instance_type = "t2.micro"
  name_prefix   = "${var.name}_launch_configuration"
}

resource "aws_autoscaling_group" "ec2_autoscaling_group" {
  name                      = "${var.name}_autoscaling_group"

  vpc_zone_identifier        = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id, aws_subnet.private_subnet_c.id]

  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1

  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.ec2_launch_configuration.id
    version = "$Latest"
  }
}

resource "aws_ecs_capacity_provider" "ec2_capacity_provider" {
  name                      = "${var.name}_capacity_provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ec2_autoscaling_group.arn
  }
}


# -- ecs cluster

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name}_cluster"

  capacity_providers = [aws_ecs_capacity_provider.ec2_capacity_provider.name]
}
