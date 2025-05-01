#!/bin/bash

# Set the desired concurrent execution limit
DESIRED_LIMIT=10000

# Get current AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Get current AWS region from pyproject.toml
AWS_REGION=$(uvx --from=toml-cli toml get --toml-path=pyproject.toml tool.infrastructure.aws_region)

echo "🔍 Requesting Lambda concurrent execution quota increase for account ${ACCOUNT_ID} in region ${AWS_REGION}"

# Submit service quota increase request
if aws service-quotas request-service-quota-increase \
  --service-code lambda \
  --quota-code L-B99A9384 \
  --desired-value ${DESIRED_LIMIT} \
  --region ${AWS_REGION}; then
  
  echo "✅ Quota increase request submitted successfully"
  echo "ℹ️  You can check the status of your request in the AWS Service Quotas console"
  echo "ℹ️  The request may take a few days to be processed by AWS"

else
  # Check if it's because a request already exists
  if [[ $? == 254 ]]; then
    echo "⚠️  A quota increase request is already pending for this service"
    echo "ℹ️  Please check the AWS Service Quotas console for the status"
    exit 0
  else
    echo "❌ Failed to submit quota increase request"
    exit 1
  fi
fi
