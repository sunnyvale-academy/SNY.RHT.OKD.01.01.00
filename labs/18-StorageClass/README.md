# StorageClass

For a Kubernetes cluster with multiple worker nodes, the cluster admin needs to create persistent volumes that are mountable by containers running on any node and matching the capacity and access requirements in each persistent volume claim. Cloud provider managed Kubernetes clusters from IBM, Google, AWS, and others support dynamic volume provisioning. As a developer you can request a dynamic persistent volume from these services by including a storage class in your persistent volume claim.

In this tutorial, you will see how to add a dynamic NFS provisioner that runs as a container for a local Kubernetes cluster.

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


## Test the Class with a Persistent Volume Claim

```console
$ oc create -f pvc.yaml 
persistentvolumeclaim/my-pvc created
```

Check the pvc status that must be **Bound**

```console
$ oc get pv
NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                                                 STORAGECLASS   REASON   AGE
...
pv0019   100Gi      RWO,ROX,RWX    Recycle          Bound       test/test-pvc                                                                 28d
...
```

Deleting the PersistentVolumeClaim will cause the provisioner to release the PersistentVolume and its data.

```console
$ oc delete -f pvc.yaml 
persistentvolumeclaim "test-pvc" deleted
```

```console
$ oc get pv
NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                                                 STORAGECLASS   REASON   AGE
...
pv0019   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
```