#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NAMESPACE='vault'
export CA_BUNDLE=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}')

${DIR?}/cleanup.sh

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update


kubectl create namespace vault
kubectl create namespace postgres
kubectl create namespace app

helm install tls-test --namespace=${NAMESPACE?} ${DIR?}/tls

kubectl get secret tls-test-client --namespace=vault -o json | \
  jq 'del(.metadata.namespace,.metadata.resourceVersion,.metadata.uid) | .metadata.creationTimestamp=null' | \
  kubectl apply --namespace=app -f -

kubectl create secret generic demo-vault \
    --from-file ${DIR?}/configs/app-policy.hcl \
    --from-file ${DIR?}/configs/bootstrap.sh \
    --namespace=${NAMESPACE?}

kubectl label secret demo-vault app=vault-agent-demo \
    --namespace=${NAMESPACE?}

${DIR?}/postgres/run.sh
${DIR?}/efk/run.sh

helm install vault \
  --namespace="${NAMESPACE?}" \
  -f ${DIR?}/values.yaml hashicorp/vault
