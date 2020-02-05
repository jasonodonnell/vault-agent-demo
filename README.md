# Vault Agent Injector Example

This demo requires `Helm V2`.

Additionally make sure Helm is installed with RBAC:

```bash
kubectl -n kube-system create serviceaccount tiller

kubectl create clusterrolebinding tiller \
  --clusterrole cluster-admin \
  --serviceaccount=kube-system:tiller

helm init --service-account tiller
```

## Demo

Run the setup script that installs:

* Vault
* Vault Agent Injector
* PostgreSQL (for example)

```bash
./setup.sh
```

Vault will automatically [init, unseal, load auth methods, load policies and setup roles](https://github.com/jasonodonnell/vault-agent-demo/blob/master/configs/bootstrap.sh).

To get the root token or unseal keys for Vault, look in the `/tmp` directory in the `vault-0` pod.

## Namespaces

The demo is running in three different namespaces: `vault`, `postgres` and `app`.

```bash
kubectl get pods -n vault

kubectl get pods -n postgres

# App won't have pods running into the examples are started
kubectl get pods -n app
```

## App

Run the app demo:

```bash
cd ./examples/app
./run.sh
```

Observe no secrets/sidecars on the app pod:

```bash
kubectl describe pod <name of pod> -n app

kubectl exec -ti <name of app pod> -n app -c app -- ls /vault/secrets
```

Patch the app:

```bash
./patch.sh
```

Observe the secrets at:

```bash
kubectl describe pod <name of pod> -n app

kubectl exec -ti <name of app pod> -n app -c app -- ls /vault/secrets
```

Port forward and open the webpage:

```bash
kubectl port-forward <name of app pod> -n app 8080:8080

open https://127.0.0.1:8080
```

## Job (PostgreSQL Logical Backup)

Run the `pg_dump` job:

```bash
cd ./examples/pg_dump

./run.sh

kubectl get pods -n app
```

Observe the logs to show that it connected to PostgreSQL and created a logical 
backup to `/dev/stdout`:

```bash
kubectl logs -n app <name of job pod>
```
