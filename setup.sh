#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NAMESPACE='vault'
export CA_BUNDLE=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}')

if ! command -v waypoint &> /dev/null
then
    echo "ERROR: Cannot find 'waypoint' binary"
    exit 1
fi

${DIR?}/cleanup.sh

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

kubectl create namespace vault
kubectl create namespace postgres
kubectl create namespace app
kubectl create namespace waypoint

helm install tls-test --namespace=${NAMESPACE?} ${DIR?}/tls

kubectl get secret tls-test-client --namespace=${NAMESPACE?} --export -o yaml |\
  kubectl apply --namespace=app -f -

kubectl create secret generic demo-vault \
    --from-file ${DIR?}/configs/app-policy.hcl \
    --from-file ${DIR?}/configs/bootstrap.sh \
    --namespace=${NAMESPACE?}

kubectl label secret demo-vault app=vault-agent-demo \
    --namespace=${NAMESPACE?}

${DIR?}/postgres/run.sh

helm install vault \
  --namespace="${NAMESPACE?}" \
  -f ${DIR?}/values.yaml hashicorp/vault --version=0.7.0

kubectl create namespace waypoint
waypoint install -platform=kubernetes -namespace=waypoint -accept-tos -server-image=hashicorp/waypoint:0.1.5

kubectl config set-context --current --namespace=app
