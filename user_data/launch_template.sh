#!/bin/bash

# Install ECS agent
yum update -y
yum install -y amazon-ecs-agent

# Start ECS agent
start ecs
