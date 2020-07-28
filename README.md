# Vault Helm Raft TLS Example

This demo requires `Helm V3`.

## Prerequisites

* The file `${HOME?}/credentials.json` must exist containing GCP credentials for KMS auto-unseal.

## Demo

Run the setup script that installs:

* Vault
* Vault Agent Injector

```bash
./setup.sh
```

## Init and Join

```bash
kubectl exec -ti vault-0 -n vault -- vault operator init
```

```bash
kubectl exec -ti vault-1 -n vault -- vault operator raft join -leader-ca-cert=@/vault/userconfig/tls-test-server/ca.crt https://vault-0.vault-internal:8200
kubectl exec -ti vault-2 -n vault -- vault operator raft join -leader-ca-cert=@/vault/userconfig/tls-test-server/ca.crt https://vault-0.vault-internal:8200
```
