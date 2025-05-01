#!/bin/bash
set -e
STAGE=$1
ACTION=$2  # Will be "plan" or "apply"
source ./scripts/set-env.sh $STAGE

echo "
========================================
🚀 LAUNCHING TERRAFORM ACTION WITH STAGE: $STAGE AND ACTION: $ACTION
========================================
"
# Generate api documentation
make generate-openapi-files-$STAGE

echo "
========================================
🚀 EXECUTING TERRAFORM $ACTION
========================================
"
# If action is plan, add the -out flag
if [ "$ACTION" = "plan" ]; then
terraform -chdir=.infra/terraform plan -var-file="$STAGE.tfvars.json"
fi

# If action is apply, add the -auto-approve flag
if [ "$ACTION" = "apply" ]; then

  terraform -chdir=.infra/terraform apply  -var-file="$STAGE.tfvars.json"
  terraform -chdir=.infra/terraform output -json > .infra/terraform/$STAGE-outputs.json
fi

if [ "$ACTION" = "apply-ecr" ]; then
  terraform -chdir=.infra/terraform apply -target=aws_ecr_repository.this -var-file="$STAGE.tfvars.json"
fi

if [ "$ACTION" = "destroy" ]; then
  terraform -chdir=.infra/terraform destroy -var-file="$STAGE.tfvars.json"
fi
