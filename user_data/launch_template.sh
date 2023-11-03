#!/bin/bash

yum update -y

# Install ECS agent
yum install -y amazon-ecs-agent

# Install SSM agent
yum install -y amazon-ssm-agent

# Start ECS agent
systemctl start ecs

# Start SSM agent
systemctl start amazon-ssm-agent