#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

kubectl create -f ${DIR?}/service-account.yaml

cat <<EOF | kubectl create -f -
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: app
  labels:
    app: vault-agent-demo
spec:
  replicas: 1
  template:
    metadata:
      annotations:
      labels:
        app: vault-agent-demo
    spec:
      serviceAccountName: vault-agent
      containers:
      - name: app
        image: hashicorp/app:0.0.1
EOF
