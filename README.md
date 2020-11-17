# Vault Agent Injector Waypoint Example

This demo requires `Helm V3`.

## Demo

Run the setup script that installs:

* Vault
* Vault Agent Injector
* PostgreSQL (for example)
* Waypoint Server

```bash
./setup.sh
```

Vault will automatically [init, unseal, load auth methods, load policies and setup roles](https://github.com/jasonodonnell/vault-agent-demo/blob/hashiconf/configs/bootstrap.sh).

To get the root token or unseal keys for Vault, look in the `/tmp` directory in the `vault-0` pod.

## Namespaces

The demo is running in four different namespaces: `vault`, `postgres`, `waypoint` and `app`.

```bash
kubectl get pods -n vault

kubectl get pods -n postgres

kubectl get pods -n waypoint

# App won't have pods running into the examples are started
kubectl get pods -n app
```

## Waypoint Demo

```bash
cd ./examples/waypoint
waypoint init
waypoint up
```

Once deployed, use the URL provided by Waypoint to view the application.
