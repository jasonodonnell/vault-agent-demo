# Vault Agent Demo

HashiConf Demo!

## Requirements

* `openssl`
* `kubectl`: https://kubernetes.io/docs/tasks/tools/install-kubectl/
* Minikube: https://minikube.sigs.k8s.io/docs/start/
* Virtualbox: https://www.virtualbox.org
* Helm: https://helm.sh/docs/using_helm/

## Minikube 

```bash
$ minikube start

$ helm init --history-max 200
```

## Build

```bash
$ cd ./src

$ eval $(minikube docker-env)

$ make build
```

## Setup Vault

```bash
$ ./setup.sh

$ cd helm/

$ helm install --name=vault .

$ kubectl exec -ti vault-0 -- /vault/userconfig/demo-vault/bootstrap.sh
```

## Demo

```bash
$ cd ../app

$ ./run.sh
```

In a separate terminal:

```bash
$ kubectl port-forward $(kubectl get pod -l "app=vault-agent-demo" -o name) 8200:8200 
```

```bash
$ ./patch.sh
```

Will need to restart `port-forward` since the name changed:

```bash
$ kubectl port-forward $(kubectl get pod -l "app=vault-agent-demo" -o name) 8200:8200
```
