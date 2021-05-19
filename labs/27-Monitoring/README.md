# Monitoring

![Kubernetes](https://img.shields.io/badge/Kubernetes-informational?logo=Kubernetes&color=blue&logoColor=white&style=for-the-badge&logoWidth=30)

![OpenShift](https://img.shields.io/badge/OpenShift-informational?logo=Red%20Hat%20Open%20Shift&color=black&logoColor=red&style=for-the-badge&logoWidth=30)

## Prerequisites

Having completed the following labs:

- [00 - Prerequisites](../00-Prerequisites/README.md)
- [02 - Provision the environment](../02-Provision_the_environment/README.md)
- [03 - OKD login](../03-OKD_login/README.md)
- [04 - Project](../04-Project/README.md)

Having logged in using the **kubeadmin** account:

```console
$ oc login -u kubeadmin -p dpDFV-xamBW-kKAk3-Fi6Lg https://api.crc.testing:6443
Login successful.

You have access to 58 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "test".
```

Make sure to use the **test** project.

```console
$ oc project test
Already on project "test" on server "https://api.crc.testing:6443".
```

## Enanble monitoring 

Before running this lab, you have to enable monitoring API (thus the **cluster-monitoring-operator** operator)

Run this command, and note down the integer ID near to **cluster-monitoring-operator** (in this case is **0**).

```
$ oc get clusterversion version -ojsonpath='{range .spec.overrides[*]}{.name}{"\n"}{end}' | nl -v 0
     0  cluster-monitoring-operator
     1  machine-config-operator
     2  etcd-quorum-guard
     3  machine-api-operator
     4  cluster-autoscaler-operator
     5  insights-operator
     6  prometheus-k8s
     7  cloud-credential-operator
     8  csi-snapshot-controller-operator
     9  cluster-storage-operator
    10  kube-storage-version-migrator-operator
    11  cluster-node-tuning-operator
```

Then, run this command below using the integer ID you took from the last one as the final element of path **/spec/overrides/** (in this case the result path will be **/spec/overrides/0**).

```console
$ oc patch clusterversion/version --type='json' -p '[{"op":"remove", "path":"/spec/overrides/0"}]'  
clusterversion.config.openshift.io/version patched
```

In this way, after a couple of minutes, all the necessary Pods will be up and running and let you inspect the OpenShift cluster metrics.

To check that everything works as expected (pay attention to be logged in as **kubeadmin**):

```console
$ oc get pods -n openshift-monitoring
NAME                                          READY   STATUS       RESTARTS   AGE
alertmanager-main-0                           5/5     Running      0          7h15m
alertmanager-main-1                           5/5     Running      0          7h15m
alertmanager-main-2                           5/5     Running      0          7h15m
cluster-monitoring-operator-f557f6c97-gmt8m   2/2     Running      0          7h17m
grafana-689d8d5766-5nw5m                      2/2     Running      0          7h16m
kube-state-metrics-cf7bc857f-6n88b            3/3     Running      0          7h16m
node-exporter-9m82c                           2/2     Running      0          7h16m
openshift-state-metrics-85b46b6f6c-5cvwn      3/3     Running      0          58m
openshift-state-metrics-85b46b6f6c-rpm48      0/3     Preempting   0          61m
openshift-state-metrics-85b46b6f6c-zn6vp      0/3     Preempting   0          7h16m
prometheus-adapter-5cfd948cd8-9lfwg           1/1     Running      0          7h16m
prometheus-adapter-5cfd948cd8-kfjkj           1/1     Running      0          7h16m
prometheus-k8s-0                              7/7     Running      1          7h14m
prometheus-k8s-1                              7/7     Running      1          7h14m
prometheus-operator-6867b84869-4h65k          2/2     Running      3          7h16m
telemeter-client-77f9c75896-dgdzh             3/3     Running      0          7h16m
thanos-querier-5f6dc9f8c5-6qgb2               4/4     Running      1          7h16m
thanos-querier-5f6dc9f8c5-p64lq               4/4     Running      1          7h16m
```

If one ore more Pods are not **Running** can be a memory/cpu issue. To increase the resources of CRC VM plase have a look of the [Provision the environment lab](../02-Provision_the_environment/4.x/CodeReadyContainers/README.md)


## Prometheus Operator endpoint to scrape autoconfiguration

Next step is to build upon this configuration to start monitoring any other services deployed in your cluster.

There are two custom resources involved in this process:

- The Prometheus CRD
  - Defines Prometheus server pod metadata
  - Defines # of Prometheus server replicas
  - Defines Alertmanager(s) endpoint to send triggered alert rules
  - Defines labels and namespace filters for the 
    - ServiceMonitor CRDs that will be applied by this Prometheus server deployment

- The ServiceMonitor objects will provide the dynamic target endpoint configuration
  - The ServiceMonitor CRD
  - Filters endpoints by namespace, labels, etc
  - Defines the different scraping ports
  - Defines all the additional scraping parameters like scraping interval, protocol to use, TLS credentials, re-labeling policies, etc.

The Prometheus object filters and selects N ServiceMonitor objects, which in turn, filter and select N Prometheus metrics endpoints.

If there is a new metrics endpoint that matches the ServiceMonitor criteria, this target will be automatically added to all the Prometheus servers that select that ServiceMonitor.

![Service Monitors](img/prometheus_operator_servicemonitor.png)

As you can see in the diagram above, the ServiceMonitor targets Kubernetes services, not the endpoints directly exposed by the pod(s).

We already have a Prometheus deployment monitoring all the Kubernetes internal metrics (kube-state-metrics, node-exporter, Kubernetes API, etc) and we want to use the same to monitor also our applications.

We need a service to scrape: CoreDNS is a fast and flexible DNS server that exposes Prometheus metrics out of the box (using port 9153), we will use it for testing ServiceMonitors.

```console
$ helm repo add coredns https://coredns.github.io/helm
"coredns" has been added to your repositories
```

```console
$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "coredns" chart repository
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈
```

```console
$ helm install coredns --namespace=coredns coredns/coredns --create-namespace --set prometheus.service.enabled=true
NAME: coredns
LAST DEPLOYED: Wed May  5 22:30:56 2021
NAMESPACE: coredns
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CoreDNS is now running in the cluster as a cluster-service.

It can be tested with the following:

1. Launch a Pod with DNS tools:

kubectl run -it --rm --restart=Never --image=infoblox/dnstools:latest dnstools

2. Query the DNS server:

/ # host kubernetes
```

CoreDNS expose its metrics at port 9153

```
$ kubectl get svc -n coredns
NAME                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
coredns-coredns           ClusterIP   10.108.222.137   <none>        53/UDP,53/TCP   3s
coredns-coredns-metrics   ClusterIP   10.105.181.229   <none>        9153/TCP        3s
```

Let's apply the [ServiceMonitor](coredns-servicemonitor.yaml)

```
$ kubectl apply -f coredns-servicemonitor.yaml 
servicemonitor.monitoring.coreos.com/coredns-servicemonitor created
```

If you go back to our Prometheus instance GUI after a few minutes lates (using port-forward on port 9090->9090), you should see a new target being monitored (our CoreDNS instance)

![Prometheus Target](img/7.png)

And metrics should have popped out as well

![Prometheus Metrics](img/8.png)

## Prometheus Operator – How to configure Alert Rules

In the existing Prometheus deployment there is a configuration block to filter and match these objects:

```yaml
ruleSelector:
      matchLabels:
        app: kube-prometheus-stack
        release: prometheus
```

If you define an object containing the PromQL rules you desire and matching the desired metadata, they will be automatically added to the Prometheus servers’ configuration.

This object is described in [dead-man-switch-rule.yaml](dead-man-switch-rule.yaml), let's apply it.

```
$ kubectl apply -f dead-man-switch-rule.yaml
servicemonitor.monitoring.coreos.com/coredns-servicemonitor created
```

As soon as you apply the rule file, a new rule is being discovered by Prometheus

![Rule](img/9.png)

And since this was an always-firing rule, after a couple of minutes we should see also an alert being triggered:

![Alert](img/10.png)