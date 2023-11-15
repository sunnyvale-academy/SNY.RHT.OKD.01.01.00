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
- [04 - Project](../04-Project/README.md)
- [27 - Monitoring](../27-Monitoring/README.md)

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

If you get an error like

```
error: Metrics API not available
```

please enable the cluster monitoring using:

```console
$ crc config set enable-cluster-monitoring true
$ crc stop
$ crc start -m 15000
```

***BE AWARE:*** it takes a lot more resources and a cluster restart (don't try this at home!!! 😅 )

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
$ oc delete -f pod.yaml ; cat pod.yaml| sed -e 's/40m/130m/' | oc apply -f -
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