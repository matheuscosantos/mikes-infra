#!/bin/bash

yum update -y

# Install ECS agent
yum install -y amazon-ecs-agent

# Start ECS agent
start ecs

# Install SSM agent
yum install -y amazon-ssm-agent

# Start SSM agent
start amazon-ssm-agent
