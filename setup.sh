#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export NAMESPACE='vault'
export TLS_DIR='/tmp/injector-tls'

${DIR?}/cleanup.sh

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

kubectl create namespace vault
kubectl create namespace postgres
kubectl create namespace app

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

${DIR?}/injector-tls.sh

export CA_BUNDLE=$(cat ${TLS_DIR?}/injector-ca.crt | base64)

helm install vault \
  --namespace="${NAMESPACE?}" \
  --set "injector.certs.caBundle=${CA_BUNDLE?}" \
  -f ${DIR?}/values.yaml hashicorp/vault --version=0.7.0

kubectl scale deployment/vault-agent-injector --replicas=3 -n vault
