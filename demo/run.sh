#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

${DIR?}/cleanup.sh

kubectl create -f ${DIR?}/service-account.yaml
kubectl create -f ${DIR?}/deployment.yaml
