#!/bin/bash

IMAGE_NAME="$DOCKER_REGISTRY_USERNAME/rosyz-cartops"

echo "Logging in to Docker registry..."
echo "$DOCKER_REGISTRY_PASSWORD" | docker login -u "$DOCKER_REGISTRY_USERNAME" --password-stdin

echo "Pulling latest image..."
docker pull $IMAGE_NAME:latest

echo "Starting container..."
docker run -d \
  --name rosyz-cartops \
  -p 80:80 \
  $IMAGE_NAME:latest

