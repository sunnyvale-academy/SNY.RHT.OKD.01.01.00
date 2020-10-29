# PersistentVolume and PersistentVolumeClaim

A persistent volume (PV) is a cluster-wide resource that you can use to store data in a way that it persists beyond the lifetime of a pod. The PV is not backed by locally-attached storage on a worker node but by networked storage system such as EBS or NFS or a distributed filesystem like Ceph.


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

## Persistent volume

Type the following to list the available PV.

```console
$ oc get pv
NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                                                 STORAGECLASS   REASON   AGE
pv0001   100Gi      RWO,ROX,RWX    Recycle          Bound       openshift-image-registry/crc-image-registry-storage                           28d
pv0002   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0003   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0004   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0005   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0006   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0007   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0008   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0009   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0010   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0011   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0012   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0013   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0014   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0015   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0016   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0017   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0018   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0019   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0020   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0021   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0022   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0023   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0024   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0025   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0026   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0027   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0028   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0029   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
pv0030   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 28d
```

In order to use a PV you need to claim it first, using a persistent volume claim (PVC). The PVC requests a PV with your desired specification (size, speed, etc.) from Kubernetes/OpenShift and binds it then to a Pod where you can mount it as a volume. 

```console
$ oc create -f pvc.yaml
persistentvolumeclaim/my-pvc created
```

Now verify if the PVC is marked as **Bound**

```console
$ oc get pvc -o wide
NAME     STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE   VOLUMEMODE
my-pvc   Bound    pv0030   100Gi      RWO,ROX,RWX                   24s   Filesystem
```

In our case, the PVC is bound to the Volume using its name (more details can be found in file `pvc.yaml`).

The Pod we are going to create is made of an nginx container that mounts the volume to use it as a document root

```console
$ oc create -f nginx-pod.yaml
pod/nginx-pvc-pod created
service/nginx-nodeport-service created
```

As you can see in the output, nginx-pod.yaml also contains the declaration of a NodePort Service to let you access the webserver on port 30100.

After a few minutes, verify that the pod was created:

```console
$ oc get pods
NAME            READY   STATUS    RESTARTS   AGE
nginx-pvc-pod   1/1     Running   0          16s
```

Let's create a couple of pods that are using the same PV

```console
$ oc apply -f busybox-deployment.yaml
deployment.apps/busybox-pvc-deployment created
```

Verify if all the busybox pod replicas have been created correctly, also they should have been scheduled on both nodes.

```console
$ oc get pods -o wide
NAME                                      READY   STATUS    RESTARTS   AGE   IP            NODE                 NOMINATED NODE   READINESS GATES
busybox-pvc-deployment-594fc8f9b8-5g24g   1/1     Running   0          12s   10.116.0.64   crc-j55b9-master-0   <none>           <none>
busybox-pvc-deployment-594fc8f9b8-jtjqp   1/1     Running   0          12s   10.116.0.65   crc-j55b9-master-0   <none>           <none>
nginx-pvc-pod                             1/1     Running   0          67s   10.116.0.63   crc-j55b9-master-0   <none>           <none>
```

If you point your browser [here](http://api.crc.testing:30100) and keep refreshing the window, you should see that every 5 seconds a new entry is appended at the bottom of the page. An entry is made of the pod's hostname and a timestamp. 

What is happening here is that the two busybox pods are writing the same file in the same volume. Also, the nginx pod is mounting the same volume to read the file and present it to you.

## Cleanup

Don't forget to clean up after you:

```console
$ oc delete -f .
deployment.apps "busybox-pvc-deployment" deleted
pod "nginx-pvc-pod" deleted
service "nginx-nodeport-service" deleted
persistentvolumeclaim "my-pvc" deleted
```


