# DaemonSet

A DaemonSet make sure that all or some Kubernetes/OpenShift Nodes run a copy of a Pod. When a new node is added to the cluster, a Pod is added to it to match the rest of the nodes and when a node is removed from the cluster, the Pod is garbage collected. Deleting a DaemonSet will clean up the Pods it created.

![Kubernetes](https://img.shields.io/badge/Kubernetes-informational?logo=Kubernetes&color=blue&logoColor=white&style=for-the-badge&logoWidth=30)

![OpenShift](https://img.shields.io/badge/OpenShift-informational?logo=Red%20Hat%20Open%20Shift&color=black&logoColor=red&style=for-the-badge&logoWidth=30)


## Prerequisites

Having completed the following labs:

- [00 - Prerequisites](../00-Prerequisites/README.md)
- [02 - Provision the environment](../02-Provision_the_environment/README.md)
- [03 - OKD login](../03-OKD_login/README.md)

Having logged in using the **kubeadmin** account:

```console
$ oc login -u kubeadmin -p dpDFV-xamBW-kKAk3-Fi6Lg https://api.crc.testing:6443
Login successful.

You have access to 58 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "test".
```

## Applying DaemonSets

For this lab we use a real-life product (Fluentd) that uses DaemonSet to garuanteed that each cluster node gets its own Pod.

```console
$ oc apply -f fluentd-daemonset.yaml
serviceaccount/fluentd created
clusterrole.rbac.authorization.k8s.io/fluentd created
clusterrolebinding.rbac.authorization.k8s.io/fluentd created
daemonset.extensions/fluentd created
```

As you can see every node has got its own pod (including master)


```console
$ oc get pod -o wide -n kube-system  | grep fluent
...
fluentd-pd4lj   1/1     Running   0          97s   10.116.0.131   crc-j55b9-master-0   <none>           <none>
...
```

Since we are using a single-node cluster, only one Pod is created. If we were using a multi-node cluster we would see one Pod scheduled on each node.

DaemonSets are useful to perform some operations on each node of the cluster, in this case Fluentd take logs from nodes and pushes them to a centralized architecture (Elasticsearch).

## Cleanup

Don't forget to clean up after you:

```console
$ oc delete -f .
serviceaccount "fluentd" deleted
clusterrole.rbac.authorization.k8s.io "fluentd" deleted
clusterrolebinding.rbac.authorization.k8s.io "fluentd" deleted
daemonset.extensions "fluentd" deleted
```