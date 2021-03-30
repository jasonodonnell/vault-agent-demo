#!/bin/sh

OUTPUT=/tmp/output.txt
export VAULT_ADDR=https://127.0.0.1:8200
export VAULT_SKIP_VERIFY=true

vault operator init -n 1 -t 1 >> ${OUTPUT?}

unseal=$(cat ${OUTPUT?} | grep "Unseal Key 1:" | sed -e "s/Unseal Key 1: //g")
root=$(cat ${OUTPUT?} | grep "Initial Root Token:" | sed -e "s/Initial Root Token: //g")

vault operator unseal ${unseal?}

vault login -no-print ${root?}

# Add 'app' policy for each demo
vault policy write app /vault/userconfig/demo-vault/app-policy.hcl

# Setup Kube Auth Method
vault auth enable kubernetes

vault write auth/kubernetes/config \
   disable_iss_validation="true" \
   token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
   kubernetes_host=https://${KUBERNETES_PORT_443_TCP_ADDR}:443 \
   kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

vault write auth/kubernetes/role/app \
    bound_service_account_names=app \
    bound_service_account_namespaces=app \
    policies=app \
    token_max_ttl=20m \
    ttl=10m

# Demo 1: Static Secrets
vault secrets enable -path=secret/ kv
vault kv put secret/hashiconf hashiconf=rocks

# Demo 2: Dynamic Secrets
vault secrets enable database

vault write database/config/postgresql \
    plugin_name=postgresql-database-plugin \
    allowed_roles="db-app" \
    connection_url="postgresql://{{username}}:{{password}}@postgres.postgres.svc.cluster.local:5432/wizard?sslmode=disable" \
    username="vault" \
    password="vault"

vault write database/roles/db-app \
    db_name=postgresql \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT CONNECT ON DATABASE wizard TO \"{{name}}\"; \
        GRANT USAGE ON SCHEMA app TO \"{{name}}\"; \
        GRANT CREATE ON SCHEMA app TO \"{{name}}\"; \
        GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA app TO \"{{name}}\";" \
    revocation_statements="ALTER ROLE \"{{name}}\" NOLOGIN;"\
    default_ttl="1m" \
    max_ttl="1h"

# Demo 3: Transit
vault secrets enable transit
vault write -f transit/keys/app

vault audit enable file file_path=stdout
