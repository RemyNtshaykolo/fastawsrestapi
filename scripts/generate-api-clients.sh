#!/bin/bash

# Script to generate TypeScript clients for all API versions
# Usage: ./scripts/generate-api-clients.sh

set -e

# Directory containing the API versions
VERSIONS_DIR="src/api/versions"

# Colors for display
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Generating TypeScript clients for all API versions ===${NC}"

# Find all available versions
versions=($(find ${VERSIONS_DIR} -mindepth 1 -maxdepth 1 -type d -exec basename {} \;))

# Generate a client for each version
for version in "${versions[@]}"; do
    echo -e "${GREEN}Generating client for version ${version}...${NC}"
    
    # Create the output folder for this version
    mkdir -p "src/api/clients/${version}"
    
    # Run the application for this version to generate the openapi.json file
    APP_VERSION=${version} uv run src/api/versions/${version}/app.py
    
    # Check that the openapi.json file has been generated
    if [ -f "src/api/versions/${version}/openapi-${version}-terraform.json" ]; then
        # Generate the OpenAPI client
        npx openapi --input src/api/versions/${version}/openapi-${version}-terraform.json --output "src/api/clients/${version}" --name "ApiClient${version}"
        
        # Generate the TypeScript schema
        npx openapi-typescript src/api/versions/${version}/openapi-${version}-terraform.json --output "src/api/clients/${version}/schema.d.ts"
        
        echo -e "${GREEN}Client for version ${version} generated successfully!${NC}"
    else
        echo -e "\033[0;31mError: The OpenAPI file was not generated for version ${version}\033[0m"
    fi
done

echo -e "${BLUE}=== All clients have been generated! ===${NC}" 