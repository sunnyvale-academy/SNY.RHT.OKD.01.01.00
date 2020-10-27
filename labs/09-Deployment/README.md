# Deployment


Deployments are intended to replace Replication Controllers.  They provide the same replication functions (through Replica Sets) and also the ability to rollout changes and roll them back if necessary.

A deployment is a supervisor for pods, giving you fine-grained control over how and when a new pod version is rolled out as well as rolled back to a previous state.


![Kubernetes](https://img.shields.io/badge/Kubernetes-informational?logo=Kubernetes&color=blue&logoColor=white&style=for-the-badge&logoWidth=30)

![OpenShift](https://img.shields.io/badge/OpenShift-informational?logo=Red%20Hat%20Open%20Shift&color=black&logoColor=red&style=for-the-badge&logoWidth=30)

## Prerequisites

Having completed the following labs:

- [00 - Prerequisites](../00-Prerequisites/README.md)
- [02 - Provision the environment](../02-Provision_the_environment/README.md)
- [03 - OKD login](../03-OKD_login/README.md)
- [04 - Project](../04-Project/README.md)

Having logged in using a developer account:

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

## Create a Deployment

Let’s create a deployment with a single container based on nginx:1.7.9 image, that supervises two replicas of a pod as well as a replica set:

```console
$ oc apply -f nginx1.7.9-deployment.yaml
deployment.apps/nginx-deployment created
```

You can have a look at the deployment, as well as the the replica set and the pods the deployment looks after like so:

```console
$ oc get deployments 
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   2/2     3            3           49s

$ oc get rs
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-5bf87f5f59   2         2         2       45s

$ oc get pods
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-5bf87f5f59-f9gdx   1/1     Running   0          70s
nginx-deployment-5bf87f5f59-sd7dl   1/1     Running   0          70s
```

Let's update the deployment with a container based on nginx:latest image.

```console
$ oc apply -f nginx_latest-deployment.yaml
deployment.apps/nginx-deployment configured
```

If you type get pods, you may see the old deployment instances still running while the new deployment is creating the container
```console
$ oc get pods
NAME                                READY   STATUS              RESTARTS   AGE
nginx-deployment-5bf87f5f59-4n9k4   1/1     Running             0          63s
nginx-deployment-5bf87f5f59-plpmc   1/1     Running             0          64s
nginx-deployment-684bd4f4c-s8rmk    0/1     ContainerCreating   0          4s
```

After a while, old pod instances are terminating, the new onces are already running
```console
$ kubectl get pods
NAME                                READY   STATUS        RESTARTS   AGE
nginx-deployment-5bf87f5f59-4n9k4   0/1     Terminating   0          71s
nginx-deployment-684bd4f4c-kxsn2    1/1     Running       0          8s
nginx-deployment-684bd4f4c-s8rmk    1/1     Running       0          12s
```

At the end, pod instances stay running, the old ones are not deployed anymore
```console
$ kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-684bd4f4c-kxsn2   1/1     Running   0          22s
nginx-deployment-684bd4f4c-s8rmk   1/1     Running   0          26s
```

Also, a new replica set has been created by the deployment:

```console
$ kubectl get rs
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-5bf87f5f59   0         0         0       101s
nginx-deployment-684bd4f4c    2         2         2       41s
```

Note that during the deployment you can check the progress using **oc rollout status deploy/nginx-deployment**

```console
$ oc rollout status deploy/nginx-deployment
deployment "nginx-deployment" successfully rolled out
```

A history of all deployments is available via:

```console
$ oc rollout history deploy/nginx-deployment
deployment.extensions/nginx-deployment 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

If there are problems in the deployment OpenShift will automatically roll back to the previous version, however you can also explicitly roll back to a specific revision, as in our case to revision 1 (the original pod version):

```console
$ oc rollout undo deploy/nginx-deployment --to-revision=1
deployment.extensions/nginx-deployment rolled back

$ oc rollout history deploy/nginx-deployment
deployment.extensions/nginx-deployment 
REVISION  CHANGE-CAUSE
2         <none>
3         <none>
```

At this point in time we’re back at where we started

```console
$ kubectl get rs   
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-5bf87f5f59   2         2         2       2m54s
nginx-deployment-684bd4f4c    0         0         0       114s
```

What if we want to manually scale this deployment with replica = 10?

```console
$ oc scale --replicas=10 deployment/nginx-deployment
deployment.extensions/nginx-deployment scaled
```

Verify the pods scaling

```console
$ oc get pods
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-5bf87f5f59-8dr26   1/1     Running   0          16s
nginx-deployment-5bf87f5f59-c2qhn   1/1     Running   0          16s
nginx-deployment-5bf87f5f59-chkdb   1/1     Running   0          16s
nginx-deployment-5bf87f5f59-hdgpr   1/1     Running   0          65s
nginx-deployment-5bf87f5f59-l9p4d   1/1     Running   0          16s
nginx-deployment-5bf87f5f59-mrpqd   1/1     Running   0          16s
nginx-deployment-5bf87f5f59-rnfqr   1/1     Running   0          60s
nginx-deployment-5bf87f5f59-sscxr   1/1     Running   0          16s
nginx-deployment-5bf87f5f59-vwkx2   1/1     Running   0          16s
nginx-deployment-5bf87f5f59-xg5vj   1/1     Running   0          17s
```


Let's verify how pods have been balanced between nodes (this works only on a real multi-node OpenShift custer)

```console
$ oc get pods -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP            NODE    NOMINATED NODE   READINESS GATES
nginx-deployment-5bf87f5f59-8dr26   1/1     Running   0          59s    10.116.0.84   crc-j55b9-master-0   <none>           <none>
nginx-deployment-5bf87f5f59-c2qhn   1/1     Running   0          59s    10.116.0.78   crc-j55b9-master-0   <none>           <none>
nginx-deployment-5bf87f5f59-chkdb   1/1     Running   0          59s    10.116.0.81   crc-j55b9-master-0   <none>           <none>
nginx-deployment-5bf87f5f59-hdgpr   1/1     Running   0          108s   10.116.0.76   crc-j55b9-master-0   <none>           <none>
nginx-deployment-5bf87f5f59-l9p4d   1/1     Running   0          59s    10.116.0.79   crc-j55b9-master-0   <none>           <none>
nginx-deployment-5bf87f5f59-mrpqd   1/1     Running   0          59s    10.116.0.85   crc-j55b9-master-0   <none>           <none>
nginx-deployment-5bf87f5f59-rnfqr   1/1     Running   0          103s   10.116.0.77   crc-j55b9-master-0   <none>           <none>
nginx-deployment-5bf87f5f59-sscxr   1/1     Running   0          59s    10.116.0.83   crc-j55b9-master-0   <none>           <none>
nginx-deployment-5bf87f5f59-vwkx2   1/1     Running   0          59s    10.116.0.82   crc-j55b9-master-0   <none>           <none>
nginx-deployment-5bf87f5f59-xg5vj   1/1     Running   0          60s    10.116.0.80   crc-j55b9-master-0   <none>           <none>
```

Finally, to clean up, we remove the deployment and with it the replica sets and pods it supervises:

```console
$ oc delete deploy nginx-deployment
deployment.extensions "nginx-deployment" deleted
```

```console
$ oc get pods
No resources found in test namespace.
```