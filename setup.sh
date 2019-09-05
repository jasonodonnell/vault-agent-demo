#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NAMESPACE='demo'
export CA_BUNDLE=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}')

${DIR?}/cleanup.sh

kubectl create namespace demo
kubectl config set-context --current --namespace=demo

${DIR?}/configs/webhook-tls-generator.sh \
    --service vault-injector-svc \
    --secret vault-injector-certs \
    --namespace $(kubectl config view --minify --output 'jsonpath={..namespace}')

kubectl label secret vault-injector-certs app=vault-agent-demo \
    --namespace=${NAMESPACE?}

sed -i "s/^    caBundle:.*/    caBundle: \"${CA_BUNDLE?}\"/" ${DIR?}/helm/values.yaml

kubectl create secret generic demo-vault \
    --from-file ${DIR?}/configs/policy.hcl \
    --from-file ${DIR?}/configs/bootstrap.sh \
    --namespace=${NAMESPACE?}

kubectl label secret demo-vault app=vault-agent-demo \
    --namespace=${NAMESPACE?}
