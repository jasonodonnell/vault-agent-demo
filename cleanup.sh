#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CONFIG="configmap,serviceaccount,secret"
DEPLOY="deployment,pod,replicaset,service,statefulset"
DEPLOY="clusterrole,clusterrolebinding"
OBJECTS="${CONFIG?},${DEPLOY?}"

kubectl delete ${OBJECTS?} --selector=app=vault-agent-demo --namespace=vault
kubectl delete ${OBJECTS?} --selector=app=vault-agent-demo --namespace=app
kubectl delete ${OBJECTS?} --selector=app=vault-agent-demo --namespace=postgres
kubectl delete mutatingwebhookconfigurations vault-agent-injector-cfg
kubectl delete clusterrole vault-agent-injector-clusterrole secretprovidersyncing-role secretproviderclasses-role
kubectl delete clusterrolebinding vault-agent-injector-binding vault-server-binding secretproviderclasses-rolebinding secretprovidersyncing-rolebinding
kubectl delete crd secretproviderclasses.secrets-store.csi.x-k8s.io secretproviderclasspodstatuses.secrets-store.csi.x-k8s.io
kubectl delete CSIDriver secrets-store.csi.k8s.io

helm delete csi-secrets-store --namespace=vault
helm delete vault --namespace=vault
helm delete tls-test
kubectl delete pvc --all
kubectl delete namespace vault postgres app

${DIR?}/postgres/cleanup.sh
