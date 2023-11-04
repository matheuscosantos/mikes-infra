provider "aws" {
  region = var.region
}

# -- ecr

resource "aws_ecr_repository" "ecr_repository" {
  name = "${var.name}_app"
}

# -- network

resource "aws_vpc" "private_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}_private_vpc"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id     = aws_vpc.private_vpc.id
  cidr_block = "10.0.0.0/20"
  map_public_ip_on_launch = true
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.name}_private_subnet_a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id     = aws_vpc.private_vpc.id
  cidr_block = "10.0.16.0/20"
  map_public_ip_on_launch = true
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.name}_private_subnet_b"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.private_vpc.id

  tags = {
    Name = "${var.name}_internet_gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.private_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "subnet_a_route_table_association" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet_b_route_table_association" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.route_table.id
}

# -- security group

resource "aws_security_group" "security_group" {
  name        = "${var.name}_security_group"
  vpc_id      = aws_vpc.private_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -- ecs cluster

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name}_cluster"
}

# -- creating launch template

data "aws_ami" "amazon_linux_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.name}_ec2_role"
  assume_role_policy = file("iam/role/ec2_role.json")
}

resource "aws_iam_policy_attachment" "ec2_role_ec2_policy_attachment" {
  name       = "${var.name}_ec2_role_ec2_policy_attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_policy_attachment" "ec2_role_ssm_policy_attachment" {
  name       = "${var.name}_ec2_role_ssm_policy_attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "ec2_role_cloud_watch_policy_attachment" {
  name       = "${var.name}_ec2_role_cloud_watch_policy_attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.name}_instance_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_launch_template" "ec2_launch_configuration" {
  image_id      = data.aws_ami.amazon_linux_ami.id
  instance_type = "t2.micro"
  name_prefix   = "${var.name}_launch_configuration"

  vpc_security_group_ids = [aws_security_group.security_group.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ecs-instance"
    }
  }

  user_data = filebase64("user_data/launch_template.sh")
}

# -- creating autoscaling group

resource "aws_autoscaling_group" "ec2_autoscaling_group" {
  name                      = "${var.name}_autoscaling_group"

  vpc_zone_identifier        = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]

  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1

  launch_template {
    id      = aws_launch_template.ec2_launch_configuration.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

# -- creating capacity providers

resource "aws_ecs_capacity_provider" "ec2_capacity_provider" {
  name                      = "${var.name}_capacity_provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ec2_autoscaling_group.arn

    managed_scaling {
      maximum_scaling_step_size = 10000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = [
    aws_ecs_capacity_provider.ec2_capacity_provider.name
  ]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ec2_capacity_provider.name
  }
}
