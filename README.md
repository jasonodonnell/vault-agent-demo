# Vault + EFK + K8s Centralized Logging Example

This demo requires `Helm V3` and `jq` to be installed.

## Demo

Run the setup script that installs:

* Vault
* Vault Agent Injector
* PostgreSQL (for example)
* Elastic Search
* Fluentd
* Kibana

```bash
./setup.sh
```
**Note: this may take several minutes before its ready. Elastic Search and Kibana are very slow to start.**

Vault will automatically [init, unseal, load auth methods, load policies and setup roles](https://github.com/jasonodonnell/vault-agent-demo/blob/efk/configs/bootstrap.sh).

To get the root token or unseal keys for Vault, look in the `/tmp` directory in the `vault-0` pod.

## Namespaces

The demo is running in three different namespaces: `kube-logging`, `vault`, `postgres` and `app`.

```bash
kubectl get pods -n kube-logging

kubectl get pods -n vault

kubectl get pods -n postgres
```

## Kibana Example

Assuming everything is running in all pods, port forward to the Kibana pod:

```bash
kubectl port-forward -n kube-logging <name of kibana pod> 5601:5601
```

Next, run the following command to open Kibana in your browser:

```bash
open 127.0.0.1:5601
```

**The following instructions were lifted from [Digital Ocean's great blogpost](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-elasticsearch-fluentd-and-kibana-efk-logging-stack-on-kubernetes).**

Click on Discover in the left-hand navigation menu:

![](https://assets.digitalocean.com/articles/kubernetes_efk/kibana_discover.png)

You should see the following configuration window:

![](https://assets.digitalocean.com/articles/kubernetes_efk/kibana_index.png)

You’ll then be brought to the following page:

![](https://assets.digitalocean.com/articles/kubernetes_efk/kibana_index_settings.png)

This allows you to configure which field Kibana will use to filter log data by time. In the dropdown, select the @timestamp field, and hit Create index pattern.

Now, hit Discover in the left hand navigation menu.

![](https://assets.digitalocean.com/articles/kubernetes_efk/kibana_logs.png)

Next, filter the logs using the following filter:
```
kubernetes.pod_name:vault-0
```

You can click into any of the log entries to see additional metadata like the container name, Kubernetes node, Namespace, and more.
