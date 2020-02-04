# Vault Agent Injector Example

Run the setup script that installs:

* Vault
* Vault Agent Injector
* PostgreSQL (for example)

```bash
./setup.sh
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
