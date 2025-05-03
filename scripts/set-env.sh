#!/bin/bash
set -e

# Set default stage or use the passed parameter
STAGE=${1:-"dev"}

# execute the python script
python ./scripts/set-env.py $STAGE

set -a
source .env.$STAGE
set +a



