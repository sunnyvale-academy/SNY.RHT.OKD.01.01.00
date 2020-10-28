# Service

Kubernetes/OpenShift Pods are mortal. They are born and when they die, they are not resurrected. If you use a Deployment to run your app, it can create and destroy Pods dynamically.
Each Pod gets its own IP address, however in a Deployment, the set of Pods running in one moment in time could be different from the set of Pods running that application a moment later.
This leads to a problem: if some set of Pods (call them “backends”) provides functionality to other Pods (call them “frontends”) inside your cluster, how do the frontends find out and keep track of which IP address to connect to, so that the frontend can use the backend part of the workload?

Services solve this problem mapping requests to Pod using selectors.

![Service routing](img/service-route.gif)


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

## Service types

There are three types of services:

- **ClusterIP** – The default value. The service is only accessible from within the Kubernetes cluster – you can’t make requests to your Pods from outside the cluster!
- **NodePort** – This makes the service accessible on a static port on each Node in the cluster. This means that the service can handle requests that originate from outside the cluster.
- **LoadBalancer** – The service becomes accessible externally through a cloud provider's load balancer functionality. GCP, AWS, Azure, and OpenStack offer this functionality. The cloud provider will create a load balancer, which then automatically routes requests to your Kubernetes Service


## ClusterIP


To try this demo, let's create a Deployment to spawn 2 nginx Pod (replicas=2).

```console
$ oc apply -f  nginx_latest-deployment.yaml 
deployment.apps/nginx-deployment created
```

To check if the Pods are running, after a few minutes type:

```console
$ oc get deployments -o wide 
NAME               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES         SELECTOR
nginx-deployment   2/2     2            2           11s   nginx        nginx:latest   app=nginx
```

If you see 2/2 it means everything worked as expected.

Creating a Service means allowing the access to that Pods

```console
$ oc apply -f service_clusterip.yaml
service/clusterip-service created
```

Let's inspect our first service (the service you create on your cluster may differ slightly)

```console
$ oc get services -o wide 
NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE   SELECTOR
clusterip-service   ClusterIP   172.25.190.223   <none>        8080/TCP         8s    app=nginx
```

This means that your Pods are accessible ONLY within the cluster with IP address **172.25.190.223** or by its **name**.

To verify it, we spawn a busybox Pod in order to contact the service's name from within the Kubernetes cluster.

```console
$ oc run -i --rm --tty busybox --image=busybox --restart=Never -- wget -qO- clusterip-service:8080 
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
pod "busybox" deleted
```

The **ClusterIP** service type is useful for backend Pods that need to be called only from within the Kubernetes cluster by other (may be frontend) Pods.

What if you want to expose your Pods to the outside world? NodePort service type is made for that.

## NodePort

```console
$ oc apply -f service_nodeport.yaml
service/clusterip-service configured
```

Your service has been created 

```console
$ oc get services 
NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
clusterip-service   ClusterIP   172.25.190.223   <none>        8080/TCP         89s
nodeport-service    NodePort    172.25.44.124    <none>        8080:30100/TCP   8s
```

```console
$ oc describe service nodeport-service 
Name:                     nodeport-service
Namespace:                test
Labels:                   <none>
Annotations:              Selector:  app=nginx
Type:                     NodePort
IP:                       172.25.44.124
Port:                     http  8080/TCP
TargetPort:               80/TCP
NodePort:                 http  30100/TCP
Endpoints:                10.116.0.47:80,10.116.0.48:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

The following command is meant to try access the service by pointing to a worker's ip address and port 30100. You can just copy & paste IP:PORT in your browser to achieve the same.


```console
$ curl api.crc.testing:30100
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```


In the case of a multi-node cluster you could point to any nodes' 30100 port, even if that node is not running the Pod, and the service still responds, why? 
Because with **NodePort** services, a port is opened on every worker node, even if there's no Pod scheduled on it. The internal Kubernetes/OpenShift SDN routes the request to the Pod instance, wherever it is.

## LoadBalancer

When the Service type is set to **LoadBalancer**, Kubernetes/OpenShift provides functionality equivalent to type equals ClusterIP to pods within the cluster and extends it by programming the (external to Kubernetes/OpenShift) load balancer with entries for the Pods.

LoadBalancer service type works only if you run Kubernetes/OpenShift on a cloud provider that support the creation of load balancers with public IP address, so this scenario can not be tested on a local Kubenrtes installation.


## Cleanup

Before ending up, delete everything we created during this lab

```console
$ oc delete service clusterip-service
service "clusterip-service" deleted

$ oc delete service nodeport-service
service "nodeport-service" deleted

$ oc delete deployment nginx-deployment
deployment.extensions "nginx-deployment" deleted
```
