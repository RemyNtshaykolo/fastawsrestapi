#!/bin/bash
set -e
source ./scripts/set-env.sh

STAGE=$1

IMAGE_NAME=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${STAGE}-${APP_NAME}:lambda

ECR_ENDPOINT=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

echo "Launching command: aws ecr get-login-password --profile ${AWS_PROFILE} --region ${AWS_REGION}|docker login --password-stdin --username AWS ${ECR_ENDPOINT}"

# Connect to ECR
aws ecr get-login-password --profile ${AWS_PROFILE} --region ${AWS_REGION}|docker login --password-stdin --username AWS ${ECR_ENDPOINT}

# Build the image for x86_64 architecture
DOCKER_BUILDKIT=1 docker build -f "Dockerfile" -t ${IMAGE_NAME} . --platform linux/amd64 --provenance=false

# Push the image to ECR
docker push "${IMAGE_NAME}"