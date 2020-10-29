# ConfigMap


![ConfigMap](img/configmap-diagram.gif)

A ConfigMap is a dictionary of key-value pairs that store configuration settings for your applications.

First, create a ConfigMap in your cluster by tweaking our sample YAML to your needs.

Second, consume to ConfigMap in your Pods and use its values.

The ConfigMap described in **nginx-cm.yaml** bring two key/value entry, the first **nginx.conf** will be used within a Nginx container to configure the webserver, the second **virtualhost.conf** will be used to configure a Virtualhost within the same Nginx container.

To understand better how ConfigMaps are declared, please have a look of [nginx-cm.yaml](nginx-cm.yaml) file.

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


## Create a ConfigMap

Let's create the CM

```console
$ oc apply -f nginx-cm.yaml
configmap/nginx-conf created
```

With the following instructions, the Nginx container uses the CM key/value entries to configure Nginx webserver:

```yaml
...
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - mountPath: /etc/nginx # mount nginx-conf volume to /etc/nginx
          readOnly: true
          name: nginx-conf
        - mountPath: /var/log/nginx
          name: log
      volumes:
      - name: nginx-conf
        configMap:
          name: nginx-conf # place ConfigMap `nginx-conf` on /etc/nginx
          items:
            - key: nginx.conf
              path: nginx.conf
            - key: virtualhost.conf
              path: virtualhost/virtualhost.conf # dig directory
      - name: log
        emptyDir: {}
...
```

Let's create the Nginx Pod

```console
$ oc apply -f nginx-deployment.yaml
deployment.apps/nginx created
```

Verify that the Pod is running

```console
$ oc get po 
NAME                     READY   STATUS    RESTARTS   AGE
nginx-7f459cf95c-f24zc   1/1     Running   0          107s
```

The Nginx container has been configured (through the ConfigMap) to proxy requests to [http://www.sunnyvale.it](http://www.sunnyvale.it) website.

To test our Nginx configuration let's create a NodePort service

```console
$ oc apply -f nginx-service.yaml 
service/nginx created
```

If everything has been configured properly, if you point your browser to [http://api.crc.testing:31719](http://api.crc.testing:31719) you should be redirected to [http://www.sunnyvale.it](http://www.sunnyvale.it) website.

## Cleanup

To remove everything you created earlier:

```console
$ oc delete -f .
configmap "nginx-conf" deleted
deployment.apps "nginx" deleted
service "nginx" deleted
```
