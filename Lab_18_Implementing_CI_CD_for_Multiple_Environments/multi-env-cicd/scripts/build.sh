#!/bin/bash
set -e

ENVIRONMENT=${1:-dev}
IMAGE_TAG=${2:-1.0.0}
IMAGE_NAME="multi-env-app"

echo "Building application for environment: $ENVIRONMENT"
echo "Image tag: ${ENVIRONMENT}-${IMAGE_TAG}"

cd src
docker build -t ${IMAGE_NAME}:${ENVIRONMENT}-${IMAGE_TAG} .
cd ..

echo "Build completed: ${IMAGE_NAME}:${ENVIRONMENT}-${IMAGE_TAG}"
