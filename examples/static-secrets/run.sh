#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

kubectl create -f ${DIR?}/service-account.yaml --namespace=app

cat <<EOF | kubectl create -n app -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  labels:
    app: vault-agent-demo
spec:
  selector:
    matchLabels:
      app: vault-agent-demo
  replicas: 1
  template:
    metadata:
      annotations:
      labels:
        app: vault-agent-demo
    spec:
      shareProcessNamespace: true
      serviceAccountName: app
      containers:
      - name: app
        image: jodonnellhashi/static-secrets-app:1.0.0
        imagePullPolicy: Always
        securityContext:
          runAsUser: 100
          runAsGroup: 1000
        env:
        - name: APP_SECRET_PATH
          value: "/vault/secrets/kv-secret"
EOF
