#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

${DIR?}/cleanup.sh

kubectl create -f ${DIR?}/service.yaml --validate=true --namespace=postgres
kubectl create -f ${DIR?}/configmap.yaml --validate=true --namespace=postgres
kubectl create -f ${DIR?}/deployment.yaml --validate=true --namespace=postgres
