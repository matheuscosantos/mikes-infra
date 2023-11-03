#!/bin/bash

sudo yum -y update

# Install and configure the CloudWatch Logs agent
sudo yum install -y awslogs
sudo service awslogs start
sudo chkconfig awslogs on

# ecs agent
sudo amazon-linux-extras disable docker
sudo amazon-linux-extras install -y ecs
echo ECS_CLUSTER=mikes_cluster >> /etc/ecs/ecs.config
sudo systemctl enable --now ecs

# ssm agent
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl start amazon-ssm-agent
