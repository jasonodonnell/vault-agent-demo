# Vault Agent Demo

HashiConf Demo!

## Requirements

* `openssl`
* `kubectl`: https://kubernetes.io/docs/tasks/tools/install-kubectl/
* Minikube: https://minikube.sigs.k8s.io/docs/start/
* Helm: https://helm.sh/docs/using_helm/

## Minikube 

Install helm notes here

## Build

```bash
cd ./src
make build
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

$ ./patch.sh
```
