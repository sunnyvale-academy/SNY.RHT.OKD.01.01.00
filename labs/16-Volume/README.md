# Volume

A Kubernetes volume is essentially a directory accessible to all containers running in a pod. In contrast to the container-local filesystem, the data in volumes is preserved across container restarts. The medium backing a volume and its contents are determined by the volume type:

- node-local types such as emptyDir or hostPath
- file-sharing types such as nfs
- cloud provider-specific types like awsElasticBlockStore, azureDisk, or gcePersistentDisk
- distributed file system types, for example glusterfs or cephfs
- special-purpose types like secret, gitRepo

A special type of volume is PersistentVolume, which we will cover elsewhere.


![Kubernetes](https://img.shields.io/badge/Kubernetes-informational?logo=Kubernetes&color=blue&logoColor=white&style=for-the-badge&logoWidth=30)

![OpenShift](https://img.shields.io/badge/OpenShift-informational?logo=Red%20Hat%20Open%20Shift&color=black&logoColor=red&style=for-the-badge&logoWidth=30)



## Prerequisites

Having completed the following labs:

- [00 - Prerequisites](../00-Prerequisites/README.md)
- [02 - Provision the environment](../02-Provision_the_environment/README.md)
- [03 - OKD login](../03-OKD_login/README.md)
- [04 - Project](../04-Project/README.md)

Having logged in using the **developer** account:

```console
$ oc login -u developer -p developer https://api.crc.testing:6443     
Login successful.

You have one project on this server: "test"

Using project "test".
```

Make sure to use the **test** project.

```console
$ oc project test
Already on project "test" on server "https://api.crc.testing:6443".
```

## Create a Volume

Let’s create a Pod with two containers that use an emptyDir Volume to exchange data:

```console
$ oc create -f pod.yaml
pod/sharevol created
```

Let's see the Pod description for the volume

```console
$ oc describe pod sharevol
Name:         sharevol
Namespace:    test
...
Containers:
  c1:
    Container ID:  
    Image:         centos:7
    Image ID:      
    Port:          <none>
    Host Port:     <none>
    Command:
      bin/bash
      -c
      sleep 10000
    State:          Waiting
      Reason:       ContainerCreating
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /tmp/xchange from xchange (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-gjtlb (ro)
  c2:
    Container ID:  
    Image:         centos:7
    Image ID:      
    Port:          <none>
    Host Port:     <none>
    Command:
      bin/bash
      -c
      sleep 10000
    State:          Waiting
      Reason:       ContainerCreating
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /tmp/data from xchange (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-gjtlb (ro)
...
Volumes:
  xchange:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     
    SizeLimit:  <unset>
...
```

We first exec into one of the containers in the pod, c1, check the volume mount and generate some data:

```console
$ oc exec -it sharevol -c c1 -- bash       

[root@sharevol /]# mount | grep xchange
/dev/sda1 on /tmp/xchange type ext4 (rw,relatime,data=ordered)
[root@sharevol /]# echo 'some data' > /tmp/xchange/data
```

When we now exec into c2, the second container running in the pod, we can see the volume mounted at /tmp/data and are able to read the data created in the previous step:

```console
$ oc exec -it sharevol -c c2 -- bash
[root@sharevol /]# mount | grep /tmp/data
/dev/sda1 on /tmp/data type ext4 (rw,relatime,data=ordered)
[root@sharevol /]# cat /tmp/data/data
some data
```
Note that in each container you need to decide where to mount the volume and that for emptyDir you currently can not specify resource consumption limits.


You can remove the pod with:

```console
$ oc delete pod/sharevol
pod "sharevol" deleted
```

As already described, this will destroy the shared volume and all its contents.