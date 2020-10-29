# StatefulSet

If you have a stateless app you want to use a deployment. However, for a stateful app you might want to use a StatefulSet. Unlike a deployment, the StatefulSet provides certain guarantees about the identity of the pods it is managing (that is, predictable names) and about the startup order. Two more things that are different compared to a deployment: for network communication you need to create a headless services and for persistency the StatefulSet manages a persistent volume per pod.

The OpenShift default StorageClass is responsible to create PV dynamically on behalf of the StatefulSet.

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

## Create the StatefulSet


In order to see how StatefulSet, StorageClass, PV and PVC play together, we will be using an educational Kubernetes-native NoSQL datastore.

```console
$ oc apply -f statefulset.yaml      
statefulset.apps/mehdb created
```

After a few minutes, let's verify if everything went smootlhy so far.


```console
$ oc get pods -o wide
NAME      READY   STATUS    RESTARTS   AGE    IP             NODE                 NOMINATED NODE   READINESS GATES
mehdb-0   1/1     Running   0          2m1s   10.116.0.107   crc-j55b9-master-0   <none>           <none>
mehdb-1   0/1     Running   0          11s    10.116.0.108   crc-j55b9-master-0   <none>           <none>
```

We now have two Pods created by the StatefulSet. Please note that the latters have a more predictable name  ending with - and a sequential number, compared to if they were created by a Deployment object.

Also, every mehdb pod has been scheduled on different node.

If you take a look of PVs, you can see that every mehdb Pod claimed its own instead of sharing one, and theire staus is **Bound** (thus PV provisioner pod worked as expected). 

```console
$ oc get pv
NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                                                 STORAGECLASS   REASON   AGE
pv0003   100Gi      RWO,ROX,RWX    Recycle          Bound       test/data-mehdb-1                                                             28d
pv0028   100Gi      RWO,ROX,RWX    Recycle          Bound       test/data-mehdb-0                                                             28d
```

This behaviour is caused by the StatefulSet's **volumeClaimTemplates** element:

```yaml
...
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteMany" ]
      resources:
        requests:
          storage: 1Gi
```

Before testing our stateful application, we need to create the corresponding headless Service. 

A headless Service is a service without a cluster IP so instead of load-balancing it will return the IPs of the associated Pods. This allows us to interact directly with the pods instead of the cluster IP.

To create an headless Service you need to specify `None` as a value for `.spec.clusterIP`.

Let's create the headless Service with the following command:

```console
$ oc apply -f headless-service.yaml
service/mehdb created
```

To see if it worked:

```console
$ oc get svc
NAME                     TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
mehdb                    ClusterIP   None             <none>        9876/TCP         8s
```

Note the **None** value under **ClusterIP** header.

Now we can check if the stateful app is working properly. To do this, we use the /status endpoint of the headless service mehdb:9876 and since we haven’t put any data yet into the datastore, we’d expect that 0 keys are reported:

```console
$ oc run -i --rm --tty busybox --image=busybox --restart=Never -- wget -qO- "mehdb:9876/status?level=full"
0
pod "busybox" deleted
```

And indeed we see 0 keys being available, reported above.


## Cleanup

Don't forget to clean up after you:

```console
$ oc delete -f .
service "mehdb" deleted
statefulset.apps "mehdb" deleted
```
