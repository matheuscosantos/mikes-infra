#!/bin/bash

sudo yum update -y

# Install SSM agent
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Start SSM agent
sudo systemctl start amazon-ssm-agent
