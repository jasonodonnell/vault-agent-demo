#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CONFIG="configmap,secret,MutatingWebhookConfiguration,serviceaccount"
DEPLOY="deployment,pod,replicaset,service,statefulset"
OBJECTS="${CONFIG?},${DEPLOY?}"

kubectl delete ${OBJECTS?} --selector=app=vault-agent
