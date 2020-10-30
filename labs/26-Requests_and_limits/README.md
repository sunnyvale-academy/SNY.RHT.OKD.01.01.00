# Requests and Limits

Within the pod configuration file cpu and memory are each a resource type for which constraints can be set at the container level. A resource type has a base unit. CPU is specified in units of cores, and memory is specified in units of bytes. Two types of constraints can be set for each resource type: requests and limits.

A **request** is the amount of that resources that the system will guarantee for the container, and Kubernetes will use this value to decide on which node to place the pod. A **limit** is the maximum amount of resources that Kubernetes will allow the container to use. In the case that request is not set for a container, it defaults to limit. If limit is not set, then if defaults to 0 (unbounded). Setting request < limits allows some over-subscription of resources as long as there is spare capacity. This is part of the intelligence built into the Kubernetes scheduler.

![Requests and Limits](img/container-resource-1.png)

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


## Applying resource requests and limits

Below is an example of a pod configuration file with requests and limits set for CPU and memory of two containers in a pod. CPU values are specified in “millicpu” and memory in MiB.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-tester-pod
spec:
  containers:
  - name: resource-tester
    image: sunnyvale/resource-tester:1.0
    command: 
      - stress
    args:  
      - --vm
      - "1"
      - --vm-bytes 
      - "40m"
      - "--vm-hang"
      - "1"
      - -v
    imagePullPolicy: Always
    resources:
      requests:
        memory: "50Mi"
        cpu: "100m"
      limits:
        memory: "100Mi"
        cpu: "900m"
```

This Pod start a container based on the Docker image **sunnyvale/resource-tester:1.0**. The image contains **stress-ng** that will be used to test pod's requests and limits in term of CPU and RAM.

```console
$ oc apply -f pod.yaml
pod/resource-tester-pod created
```

wait a few seconds then type:

```console
$ oc adm top pod resource-tester-pod 
NAME                  CPU(cores)   MEMORY(bytes)   
resource-tester-pod   4m           42Mi      
```

As you can see, we have verified the following situation:

- Pod memory demand (stress argument): 40m
- Pod memory request: 50m
- Pod memory limit: 100m
- Pod memory usage (kubectl top output): 40m

- Pod CPU request: 100m
- Pod CPU limit: 900m
- Pod CPU usage (kubectl top output): 18m

Now let's try to overload the pod memory behind its limit (100Mi) by changing the stress argument (we configure stress to take up to 150m)

```console
$ oc delete -f pod.yaml ; cat pod.yaml| sed -e 's/40m/60m/' | oc apply -f -
pod "resource-tester-pod" deleted
pod/resource-tester-pod created
```

After applying the changed configuration, the pod gets killed due to out of memory (OOMKilled).

```console
$ oc get po
NAME                  READY   STATUS      RESTARTS   AGE
resource-tester-pod   0/1     OOMKilled   0          5s
```

As you can see, we have verified the following situation:

- Pod memory demand (stress argument): 150m
- Pod memory request: 50m
- Pod memory limit: 100m
- Pod memory usage (kubectl top output): 0m

Get a more detailed view of the Container status:

```console
$ oc get po resource-tester-pod --output=yaml
...
lastState:
      terminated:
        containerID: docker://8d409bf163d1dcb1b2e1c9de417d7cfa5025cc68e7ad20e723ad2f257e3bac28
        exitCode: 1
        finishedAt: "2020-01-14T01:06:43Z"
        reason: OOMKilled
        startedAt: "2020-01-14T01:06:43Z"
...
```

The output shows that the Container was killed because it is out of memory (OOM).

If you do not specify a memory limit?

If you do not specify a memory limit for a Container, one of the following situations applies:

- The Container has no upper bound on the amount of memory it uses. The Container could use all of the memory available on the Node where it is running which in turn could invoke the OOM Killer. 

- The Container is running in a namespace that has a default memory limit, and the Container is automatically assigned the default limit. Cluster administrators can use a LimitRange to specify a default value for the memory limit.

## Cleanup

Don't forget to clean up the pod

```console
$ oc delete -f pod.yaml
pod "resource-tester-pod" deleted
```