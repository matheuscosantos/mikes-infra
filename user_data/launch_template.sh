#!/bin/bash

echo ECS_CLUSTER=mikes_cluster >> /etc/ecs/ecs.config

sudo yum -y update

sudo amazon-linux-extras disable docker

sudo amazon-linux-extras install -y ecs; sudo systemctl enable --now ecs

sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

sudo systemctl start amazon-ssm-agent
