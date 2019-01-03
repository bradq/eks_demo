#!/bin/bash

kubectl delete pod webapp-demo --namespace webapp-example

pushd terraform
terraform destroy
popd
