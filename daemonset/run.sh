#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

${DIR?}/cleanup.sh

kubectl create -f ${DIR?}/vault-agent.yaml --validate=true --namespace=vault
