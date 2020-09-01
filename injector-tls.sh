#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -d ${TLS_DIR?} ]]
then
    rm -rf ${TLS_DIR?}
fi

mkdir -p ${TLS_DIR?}
cd ${TLS_DIR?}

# CA
openssl genrsa -out injector-ca.key 2048

openssl req \
  -x509 \
  -new \
  -nodes \
  -key injector-ca.key \
  -sha256 \
  -days 1825 \
  -out injector-ca.crt \
  -subj "/C=US/ST=CA/L=San Francisco/O=HashiCorp/CN=vault-agent-injector-svc"

# Injector certs
openssl genrsa -out server.key 2048

openssl req \
  -new \
  -key server.key \
  -out server.csr \
  -subj "/C=US/ST=CA/L=San Francisco/O=HashiCorp/CN=vault-agent-injector-svc"

cat <<EOF >${TLS_DIR?}/csr.conf
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = vault-agent-injector-svc
DNS.2 = vault-agent-injector-svc.${NAMESPACE?}
DNS.3 = vault-agent-injector-svc.${NAMESPACE?}.svc
DNS.4 = vault-agent-injector-svc.${NAMESPACE?}.svc.cluster.local
EOF

openssl x509 \
  -req \
  -in server.csr \
  -CA injector-ca.crt \
  -CAkey injector-ca.key \
  -CAcreateserial \
  -out server.crt \
  -days 1825 \
  -sha256 \
  -extfile csr.conf

kubectl create secret generic injector-tls \
    --from-file ${TLS_DIR?}/server.crt \
    --from-file ${TLS_DIR?}/server.key \
    --namespace=${NAMESPACE?}

kubectl label secret injector-tls app=vault-agent-demo \
    --namespace=${NAMESPACE?}

cd ${DIR?}
