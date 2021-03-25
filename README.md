# Vault Agent Injector Example

This demo requires `Helm V3` and `jq` to be installed.

## Demo

Run the setup script that installs:

* Vault
* Vault Agent Injector
* PostgreSQL (for example)

```bash
./setup.sh
```

Vault will automatically [init, unseal, load auth methods, load policies and setup roles](https://github.com/jasonodonnell/vault-agent-demo/blob/hashiconf/configs/bootstrap.sh).

To get the root token or unseal keys for Vault, look in the `/tmp` directory in the `vault-0` pod.

## Namespaces

The demo is running in three different namespaces: `vault`, `postgres` and `app`.

```bash
kubectl get pods -n vault

kubectl get pods -n postgres

# App won't have pods running into the examples are started
kubectl get pods -n app
```

## Injector Static Secret Demo:

```bash
cd ./examples/injector/static-secrets
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

open http://127.0.0.1:8080
```

## Injector Dynamic Secret Demo:

```bash
cd ./examples/injector/dynamic-secrets
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

open http://127.0.0.1:8080
```

## Injector Transit Demo:

```bash
cd ./examples/injector/transit
./run.sh
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

open http://127.0.0.1:8080
```

## CSI Dynamic Credentials Demo

```bash
cd ./examples/csi/transit
./run.sh
```

Port forward and open the webpage:

```bash
kubectl port-forward <name of app pod> -n app 8080:8080

open http://127.0.0.1:8080
```
