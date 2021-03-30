#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CONFIG="configmap,serviceaccount,secret"
DEPLOY="deployment,pod,replicaset,service,statefulset,daemonset"
OBJECTS="${CONFIG?},${DEPLOY?}"

kubectl delete ${OBJECTS?} --selector=app=kibana --namespace=kube-logging
kubectl delete ${OBJECTS?} --selector=app=fluentd --namespace=kube-logging
kubectl delete ${OBJECTS?} --selector=app=elasticsearch --namespace=kube-logging
