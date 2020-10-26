# ReplicationController

The Replication Controller is the original form of replication in Kubernetes.  It’s being replaced by Replica Sets.

A Replication Controller is a structure that enables you to easily create multiple pods, then make sure that that number of pods always exists. If a pod does crash, the Replication Controller replaces it.

If there are too many pods, the ReplicationController terminates the extra pods. If there are too few, the ReplicationController starts more pods. Unlike manually created pods, the pods maintained by a ReplicationController are automatically replaced if they fail, are deleted, or are terminated. 

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


## Create the RC

```console
$ oc create -f nginx-rc.yaml
replicationcontroller/nginx created
```

Get informations about the RC

```console
$ oc get rc
NAME    DESIRED   CURRENT   READY   AGE
nginx   2         2         0       69s
```

Describe the RC

```console
$ oc describe rc/nginx
Name:         nginx
Namespace:    test
Selector:     app=nginx
Labels:       app=nginx
Annotations:  <none>
Replicas:     2 current / 2 desired
Pods Status:  2 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:        nginx
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age   From                    Message
  ----    ------            ----  ----                    -------
  Normal  SuccessfulCreate  30s   replication-controller  Created pod: nginx-zl6xw
  Normal  SuccessfulCreate  30s   replication-controller  Created pod: nginx-5t89g
```

Get the Pods
```console
$ oc get pods
NAME          READY   STATUS    RESTARTS   AGE
nginx-5t89g   1/1     Running   0          49s
nginx-zl6xw   1/1     Running   0          49s
```

Now try to delete a Pod, you will see the RC that suddenly recreate another instance of the same Pod template.
```console
$ oc delete pod nginx-zl6xw
pod "nginx-zl6xw" deleted
```

RC successfully ensured the derired number of Pods (2)

```console
$ kubectl get pods
NAME          READY   STATUS    RESTARTS   AGE
nginx-5t89g   1/1     Running   0          92s
nginx-85bc7   1/1     Running   0          14s
```


Finally, delete the RC

```console
$ oc delete -f nginx-rc.yaml
replicationcontroller "nginx" deleted
```

As you can see, when you delete the Replication Controller, you also delete all of the pods that it created.

```console
$ kubectl get pods
No resources found.
```