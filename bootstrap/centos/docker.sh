#!/bin/bash
# Use DOCKER_IMAGE to pull an image you want to use 

# Performs a basic Docker Installation, when you need to setup development tools or products 

# Install and enable service 
yum install -y docker
chkconfig docker on 

service docker start 

if [ -n ${DOCKER_IMAGE} ]; then 
    docker pull "${DOCKER_IMAGE}"
fi