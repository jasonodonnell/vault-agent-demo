# Vault Agent Demo

HashiConf Demo!

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
