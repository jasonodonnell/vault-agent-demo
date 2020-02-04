#!/bin/sh

OUTPUT=/tmp/output.txt
export VAULT_ADDR=https://127.0.0.1:8200
export VAULT_SKIP_VERIFY=true

vault operator init -n 1 -t 1 >> ${OUTPUT?}

unseal=$(cat ${OUTPUT?} | grep "Unseal Key 1:" | sed -e "s/Unseal Key 1: //g")
root=$(cat ${OUTPUT?} | grep "Initial Root Token:" | sed -e "s/Initial Root Token: //g")

vault operator unseal ${unseal?}

vault login -no-print ${root?}

vault policy write app /vault/userconfig/demo-vault/app-policy.hcl
vault policy write db-backup /vault/userconfig/demo-vault/pgdump-policy.hcl

vault auth enable kubernetes

vault write auth/kubernetes/config \
   token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
   kubernetes_host=https://${KUBERNETES_PORT_443_TCP_ADDR}:443 \
   kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

vault write auth/kubernetes/role/db-app \
    bound_service_account_names=app \
    bound_service_account_namespaces=app \
    policies=app \
    token_max_ttl=60s \
    ttl=30s

vault write auth/kubernetes/role/db-backup \
    bound_service_account_names=pgdump \
    bound_service_account_namespaces=app \
    policies=db-backup \
    ttl=1h

vault secrets enable database

vault write database/config/postgresql \
    plugin_name=postgresql-database-plugin \
    allowed_roles="db-app,db-backup" \
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
    default_ttl="1h" \
    max_ttl="24h"

vault write database/roles/db-backup \
    db_name=postgresql \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT CONNECT ON DATABASE wizard TO \"{{name}}\"; \
        GRANT USAGE ON SCHEMA app TO \"{{name}}\"; \
        GRANT USAGE ON SCHEMA public TO \"{{name}}\"; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\"; \
        GRANT SELECT ON ALL TABLES IN SCHEMA app TO \"{{name}}\";" \
    revocation_statements="ALTER ROLE \"{{name}}\" NOLOGIN;"\
    default_ttl="1h" \
    max_ttl="24h"

vault secrets enable pki

vault secrets tune -max-lease-ttl=8760h pki

vault write pki/root/generate/internal common_name=hashicorp.com ttl=8760h

vault write pki/config/urls \
    issuing_certificates="https://vault.vault.svc:8200/v1/pki/ca" \
    crl_distribution_points="https://vault.vault.svc:8200/v1/pki/crl"

vault write pki/roles/hashicorp-com \
    allowed_domains=hashicorp.com \
    allow_subdomains=true \
    max_ttl=72h
