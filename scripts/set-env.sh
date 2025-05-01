#!/bin/bash
set -e

# Set default stage or use the passed parameter
STAGE=${1:-"dev"}
TFVARS_JSON=".infra/terraform/${STAGE}.tfvars.json"

# Check that the stage exists in pyproject.toml
if ! uvx --from=toml-cli toml get --toml-path=pyproject.toml tool.infrastructure.aws_accounts.$STAGE &>/dev/null; then
    echo "ERROR: Stage '$STAGE' does not exist in pyproject.toml" >&2
    echo "Available stages:" >&2
    uvx --from=toml-cli toml get --toml-path=pyproject.toml tool.infrastructure.aws_accounts | grep -o '\[.*\]' | sed 's/\[//;s/\]//' | xargs -n1 echo "  -"
    exit 1
fi

# Convert pyproject.toml to JSON using python
pyproject_json=$(python -c "import toml, json; print(json.dumps(toml.load(open('pyproject.toml'))))")

# Define helper function to get values from JSON
get_value() {
    echo "$pyproject_json" | jq -c "$1"
}

# Extract values
AWS_PROFILE=$(get_value '.tool.infrastructure.aws_accounts["'"$STAGE"'"].profile')
AWS_ACCOUNT_ID=$(get_value '.tool.infrastructure.aws_accounts["'"$STAGE"'"].aws_account')
AWS_REGION=$(get_value '.tool.infrastructure.aws_region')
APP_NAME=$(get_value '.project.name')
DOMAIN_NAME=$(get_value '.tool.infrastructure.domain_name // empty')
API_KEYS=$(get_value '.tool.infrastructure.api_keys // []')
OAUTH2_CLIENTS=$(get_value '.tool.infrastructure.oauth2_clients // []')
USAGE_PLANS=$(get_value '.tool.infrastructure.usage_plans // {}')
API_VERSIONS=$(python -c "from src.utils import get_versions_list; import json; print(json.dumps(get_versions_list()))")
API_TITLE=$(get_value '.tool.infrastructure.api_title // empty')


# Export env variables
export AWS_PROFILE=$(echo "$AWS_PROFILE" | tr -d '"')
export AWS_ACCOUNT_ID=$(echo "$AWS_ACCOUNT_ID" | tr -d '"')
export AWS_REGION=$(echo "$AWS_REGION" | tr -d '"')
export DOMAIN_NAME=$(echo "$DOMAIN_NAME" | tr -d '"')
export APP_NAME=$(echo "$APP_NAME" | tr -d '"')
export TF_WORKSPACE="$STAGE"
export PYTHONPATH=$PYTHONPATH:$(pwd)/src
export API_TITLE=$(echo "$API_TITLE" | tr -d '"')


# Export env from .env file
if [ ! -f ".env.$STAGE" ]; then
    echo "ERROR: Environment file '.env.$STAGE' does not exist!" >&2
    echo "Please create this file with the required environment variables." >&2
    exit 1
fi

set -a
source .env.$STAGE
set +a

# Build the final JSON structure
jq -n \
  --arg aws_account_id "$AWS_ACCOUNT_ID" \
  --arg aws_region "$AWS_REGION" \
  --arg app_name "$APP_NAME" \
  --arg stage "$STAGE" \
  --arg aws_profile "$AWS_PROFILE" \
  --arg domain_name "$DOMAIN_NAME" \
  --argjson api_keys "$API_KEYS" \
  --argjson oauth2_clients "$OAUTH2_CLIENTS" \
  --argjson usage_plans "$USAGE_PLANS" \
  --argjson api_versions "$API_VERSIONS" \
  '{
    aws_account_id: $aws_account_id,
    aws_region: $aws_region,
    app_name: $app_name,
    stage: $stage,
    aws_profile: $aws_profile,
    domain_name: $domain_name,
    api_keys: $api_keys,
    oauth2_clients: $oauth2_clients,
    usage_plans: $usage_plans,
    api_versions: $api_versions
  }' > "$TFVARS_JSON"
