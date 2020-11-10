#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

kubectl delete daemonset,configmap --selector=app=vault-agent --namespace=vault
