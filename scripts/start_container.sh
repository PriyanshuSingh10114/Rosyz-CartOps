#!/bin/bash
set -e

IMAGE_NAME="priyanshusingh10114/rosyz-cartops:latest"
CONTAINER_NAME="rosyz-cartops"

echo "Fetching Docker Hub credentials from SSM..."

DOCKER_USER=$(aws ssm get-parameter \
  --name /rosyz/docker/username \
  --query Parameter.Value \
  --output text)

DOCKER_PASS=$(aws ssm get-parameter \
  --with-decryption \
  --name /rosyz/docker/password \
  --query Parameter.Value \
  --output text)

if [ -z "$DOCKER_USER" ] || [ -z "$DOCKER_PASS" ]; then
  echo "Docker Hub credentials are missing"
  exit 1
fi

echo "Logging in to Docker Hub..."
echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

echo "Pulling image: $IMAGE_NAME"
docker pull $IMAGE_NAME

echo "Stopping old container if exists..."
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

echo "Starting new container..."
docker run -d \
  --name $CONTAINER_NAME \
  -p 80:80 \
  $IMAGE_NAME
