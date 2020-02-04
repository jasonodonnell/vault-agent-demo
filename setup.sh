#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NAMESPACE='vault'
export CA_BUNDLE=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}')

${DIR?}/cleanup.sh

kubectl create namespace vault
kubectl create namespace postgres
kubectl create namespace app

helm delete --purge tls-test
helm install --name=tls-test --namespace=${NAMESPACE?} ${DIR?}/tls

kubectl get secret tls-test-client --namespace=${NAMESPACE?} --export -o yaml |\
  kubectl apply --namespace=app -f -

kubectl create secret generic demo-vault \
    --from-file ${DIR?}/configs/app-policy.hcl \
    --from-file ${DIR?}/configs/pgdump-policy.hcl \
    --from-file ${DIR?}/configs/bootstrap.sh \
    --namespace=${NAMESPACE?}

kubectl label secret demo-vault app=vault-agent-demo \
    --namespace=${NAMESPACE?}

${DIR?}/postgres/run.sh

helm install --name=vault \
  --namespace="${NAMESPACE?}" \
  -f ${DIR?}/values.yaml ${DIR?}/vault-helm
