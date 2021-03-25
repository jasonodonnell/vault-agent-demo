#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

kubectl create -f ${DIR?}/service-account.yaml --namespace=app
kubectl create -f ${DIR?}/secret-class.yaml --namespace=app
kubectl create -f ${DIR?}/deployment.yaml --namespace=app
