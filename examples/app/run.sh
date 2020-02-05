#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

kubectl create -f ${DIR?}/service-account.yaml --namespace=app

cat <<EOF | kubectl create -n app -f -
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
      serviceAccountName: app
      containers:
      - name: app
        image: jodonnellhashi/vault-k8s-demo-app:0.2.0
        imagePullPolicy: Always
EOF
