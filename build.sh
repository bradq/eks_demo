#!/bin/bash
# Since this is devoid of error handling, let's at least have the courtesy to bail if things go sideways
set -e

# Find the true root directory of this project
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $DIR/terraform

terraform init
terraform -vars-file bradq.tfvars plan
terraform -vars-file bradq.tfvars apply

# Configure our local Kubernetes client

# Apply pod manifest