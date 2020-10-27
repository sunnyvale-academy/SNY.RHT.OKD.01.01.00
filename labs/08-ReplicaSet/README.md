# ReplicaSet


A ReplicaSet is defined with fields, including a selector that specifies how to identify Pods it can acquire, a number of replicas indicating how many Pods it should be maintaining, and a pod template specifying the data of new Pods it should create to meet the number of replicas criteria.

ReplicaSet then fulfills its purpose by creating and deleting Pods as needed to reach the desired number. When a ReplicaSet needs to create new Pods, it uses its Pod template.

In this case, it’s more or less the same as when we were creating the ReplicationController, except we’re using matchExpressions instead of label. 

```yaml
...
spec:
   replicas: 2
   selector:
     matchExpressions:
      - {key: app, operator: In, values: [guestbook, guest-book, guest_book]}
      - {key: env, operator: NotIn, values: [production]}
...
```

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

## Create the RS

```console
$ oc create -f frontend-rs.yaml
replicaset.apps/frontend created
```

Describe the RS

```console
$ oc describe replicaset.apps/frontend
Name:         frontend
Namespace:    test
Selector:     app in (guest-book,guest_book,guestbook),env notin (production)
Labels:       app=guestbook-rs
              tier=frontend
Annotations:  <none>
Replicas:     2 current / 2 desired
Pods Status:  0 Running / 2 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=guestbook
           env=dev
  Containers:
   php-redis:
    Image:        gcr.io/google_samples/gb-frontend:v3
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age   From                   Message
  ----    ------            ----  ----                   -------
  Normal  SuccessfulCreate  11s   replicaset-controller  Created pod: frontend-ckkj9
  Normal  SuccessfulCreate  11s   replicaset-controller  Created pod: frontend-lmt85
```

Get the Pods

```console
$ oc get pods
NAME             READY   STATUS    RESTARTS   AGE
frontend-ckkj9   1/1     Running   0          8m41s
frontend-lmt85   1/1     Running   0          8m41s
```

