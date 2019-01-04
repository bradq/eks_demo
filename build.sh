#!/bin/bash
# Since this is devoid of error handling, let's at least have the courtesy to bail if things go sideways
set -e

# Find the true root directory of this project
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Little ad-hoc resource cleanup
rm -f bquellhorst-demo-auth-config-map.yml
rm -f bquellhorst-demo.cfg

# Create cluster master and worker nodes
pushd $DIR/terraform
terraform init
terraform apply
popd

# Use this cluster's configuration for the duration of the script's run
export KUBECONFIG="$DIR/bquellhorst-demo.cfg"

# Configure our local Kubernetes client with the proper cluster
kubectl config set-cluster bquellhorst-demo

# Apply master-side identity mappings
kubectl apply -f bquellhorst-demo-auth-config-map.yml

# Create namespace and deploy pod
kubectl create namespace webapp-example
kubectl apply -f sample-webapp-pods.yml
