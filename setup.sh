#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NAMESPACE='vault'

${DIR?}/cleanup.sh

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

kubectl create namespace vault

helm install tls-test --namespace=${NAMESPACE?} ${DIR?}/tls

kubectl get secret tls-test-ca --namespace=${NAMESPACE?} --export -o yaml |\
  kubectl apply --namespace=app -f -

if [[ ! -f ${HOME?}/credentials.json ]]
then
    echo "ERROR: ${HOME?}/credentials.json not found.  This is required to configure KMS auto-unseal."
    exit 1
fi

kubectl create secret generic -n vault kms-creds \
  --from-file=${HOME?}/credentials.json

helm install vault \
  --namespace="${NAMESPACE?}" \
  -f ${DIR?}/values.yaml hashicorp/vault --version=0.6.0
