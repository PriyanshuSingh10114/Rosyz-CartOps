#!/bin/bash
set -e

echo "Starting Docker installation..."

# Must run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

# Check if Docker is already installed
if command -v docker >/dev/null 2>&1; then
  echo "Docker is already installed. Skipping installation."
  docker --version
  exit 0
fi

# Update system
apt-get update -y

# Install required dependencies
apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

# Add Docker GPG key
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Enable Docker on boot
systemctl enable docker
systemctl start docker

# Verify installation
docker --version

echo "Docker installation completed successfully"

