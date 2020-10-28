# Ingress

![An ingress](img/wMIM6.png)

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


## Deploy the backends we want to access through the Ingress


First we create a **Deployment** based on nginx Docker image

```console
$ oc apply -f nginx-deployment.yaml 
deployment.apps/nginx-deployment created
```

And we expose with a **ClusterIP** service the nginx Pod

```console
$ oc apply -f nginx-svc.yaml        
service/nginx-service created  
```

Then we create a **Deployment** based on containous/whoami Docker image

```console
$ oc apply -f whoami-deployment.yaml 
deployment.apps/whoami-deployment created
```

And we expose with a **ClusterIP** service the containous/whoami Pod as well

```console
$ oc apply -f whoami-svc.yaml        
service/whoami-service created  
```

## Adding Ingress resourse to the Cluster

We still need to define the Ingress resource

```console
$ oc create -f ingress.yaml
ingress.extensions/ingress created
```
Based on the routing defined into the `ingress.yaml`file, we should get this output (you can use your browser too)


```console
$ curl -H "Host: api.crc.testing" http://api.crc.testing/whoami 
Hostname: whoami-deployment-547545f65d-zjbgf
IP: 127.0.0.1
IP: 10.244.1.42
RemoteAddr: 10.244.1.41:38634
GET /whoami HTTP/1.1
Host: 192-168-26-11.nip.io
User-Agent: curl/7.45.0
Accept: */*
Accept-Encoding: gzip
X-Forwarded-For: 10.244.1.1
X-Forwarded-Host: 192-168-26-11.nip.io
X-Forwarded-Port: 80
X-Forwarded-Proto: http
X-Forwarded-Server: traefik-ingress-5f65985cc7-h4nsj
X-Real-Ip: 10.244.1.1
```

This was the whoami home page.

```console
$ curl -H "Host: api.crc.testing" http://api.crc.testing/
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

This was the nginx home page.

To discover how the ingress routing works, please refer to the `ingress.yaml` file.

## Cleanup

Finally, clen up resources:

```console
$ oc delete -f .
ingress.extensions "ingress" deleted
deployment.apps "nginx-deployment" deleted
service "nginx-service" deleted
deployment.apps "whoami-deployment" deleted
service "whoami-service" deleted
```

