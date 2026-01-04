#!/bin/bash
echo "Stopping existing container..."

docker stop rosyz-cartops || true
docker rm rosyz-cartops || true

