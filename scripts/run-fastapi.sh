#!/bin/bash
VERSION=$1

echo -e "\n========================================"
echo -e "🚀 RUNNING FASTAPI SERVER"
echo -e "========================================\n"

# Get available versions using Python function
AVAILABLE_VERSIONS=$(python3 -c "from src.utils import get_versions_list; print('\n'.join(get_versions_list()))")

# If no version specified or invalid version, show prompt
if [ -z "$VERSION" ] || [ ! -d "src/api/versions/$VERSION" ]; then
    echo "Available versions:"
    echo "$AVAILABLE_VERSIONS" | nl
    echo ""
    read -p "Choose a version number: " VERSION_NUMBER
    VERSION=$(echo "$AVAILABLE_VERSIONS" | sed -n "${VERSION_NUMBER}p")
    
    if [ -z "$VERSION" ]; then
        echo "Invalid selection"
        exit 1
    fi
fi

echo "Running FastAPI on version ${VERSION}"

# Check if version directory exists
if [ ! -d "src/api/versions/$VERSION" ]; then
    echo "Error: Version $VERSION not found"
    exit 1
fi

export PYTHONPATH=$PYTHONPATH:$(pwd)/src
# Launch the application with specified version
uvicorn src.api.versions.$VERSION.app:app --reload
