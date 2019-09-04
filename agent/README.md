# Vault Agent Demo

HashiConf Demo!

## Setup Vault

```bash
$ helm install --name=vault --set='server.authDelegator.enabled=true' .

$ kubectl exec -ti vault-0 -- vault operator init -n 1 -t 1

$ kubectl exec -ti vault-0 -- vault operator unseal

$ vault login

$ vault policy write demo /tmp/policy.hcl

$ vault auth enable kubernetes

$ vault write auth/kubernetes/config \
   token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
   kubernetes_host=https://${KUBERNETES_PORT_443_TCP_ADDR}:443 \
   kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
   
$ vault write auth/kubernetes/role/demo \
    bound_service_account_names=vault-agent \
    bound_service_account_namespaces=demo \
    policies=demo \
    ttl=1h
    
$ vault secrets enable -path=secret/ kv
$ vault kv put secret/demo foo=bar
```

## Policy

```
path "secret/demo" {
  capabilities = ["read"]
}

path "secret/demo/" {
  capabilities = ["list"]
}
```
