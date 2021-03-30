#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

${DIR?}/cleanup.sh

kubectl create -f ${DIR?}/namespace.yaml --validate=true --namespace=kube-logging
kubectl create -f ${DIR?}/service.yaml --validate=true --namespace=kube-logging
kubectl create -f ${DIR?}/statefulset.yaml --validate=true --namespace=kube-logging
kubectl rollout status sts/es-cluster --namespace=kube-logging

kubectl create -f ${DIR?}/kibana.yaml --validate=true --namespace=kube-logging
kubectl rollout status deployment/kibana

kubectl create -f ${DIR?}/fluentd.yaml --validate=true --namespace=kube-logging
kubectl rollout status daemonset/fluentd
