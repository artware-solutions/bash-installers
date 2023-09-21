#!/bin/bash

# Check for sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo:"
  echo "sudo $0"
  exit 1
fi

# Confirm removal of existing Docker installations
read -p "This script will remove existing Docker installations. Are you sure? (y/n): " -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 1
fi

# Remove existing Docker installations
apt remove docker docker-engine docker.io containerd runc -y

# Update package list
apt update

# Install necessary dependencies
apt install ca-certificates curl gnupg lsb-release -y

# Add Docker GPG key
mkdir -p /etc/apt/keyrings && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository to sources list
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list again
apt update

# Install Docker and related packages
apt install docker-ce docker-ce-cli containerd.io docker-compose -y

# Run a test container
docker run hello-world

# Remove all containers
docker container rm $(docker container ls -aq)

# Remove all Docker images
docker image rmi -f $(docker image ls -q)

echo "Docker installation completed."
