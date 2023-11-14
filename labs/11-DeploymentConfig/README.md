# DeploymentConfig

Building on ReplicationControllers, OpenShift's adds expanded support for the software development and deployment lifecycle with the concept of DeploymentConfigs. In the simplest case, a DeploymentConfig creates a new ReplicationController and lets it start up Pods.

When you create a DeploymentConfig, a ReplicationController is created representing the DeploymentConfig’s Pod template. If the DeploymentConfig changes, a new ReplicationController is created with the latest Pod template, and a deployment process runs to scale down the old ReplicationController and scale up the new one.

Both Kubernetes **Deployments** and OpenShift **DeploymentConfigs** are supported in OpenShift Container Platform; however, it is recommended to use **Deployments** unless you need a specific feature or behavior provided by DeploymentConfigs.

### DeploymentConfig specific features

- **Automatic rollbacks**: currently, Deployments do not support automatically rolling back to the last successfully deployed ReplicaSet in case of a failure.

- **Triggers**: deployments have an implicit ConfigChange trigger in that every change in the pod template of a deployment automatically triggers a new rollout. If you do not want new rollouts on pod template changes, pause the deployment:

- **Lifecycle hooks**: deployments do not yet support any lifecycle hooks.

- **Custom strategies**: deployments do not support user-specified Custom deployment strategies yet.

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

## Add an ImageStream to work with

```console
$ oc import-image my-nginx-is:latest --from=sunnyvaleit/nginx:1.7.9-openshift --confirm
imagestream.image.openshift.io/my-nginx-is imported

Name:                   my-nginx-is
Namespace:              test
Created:                Less than a second ago
Labels:                 <none>
Annotations:            openshift.io/image.dockerRepositoryCheck=2023-10-30T07:44:08Z
Image Repository:       default-route-openshift-image-registry.apps-crc.testing/test/my-nginx-is
Image Lookup:           local=false
Unique Images:          1
Tags:                   1

latest
  tagged from sunnyvaleit/nginx:1.7.9-openshift

  * sunnyvaleit/nginx@sha256:1cd75c9545c05f8a30d4416b6f113e909213c915a7bd7ab43842d28eacf2d328
      Less than a second ago

Image Name:     my-nginx-is:1.7.9-openshift
Docker Image:   sunnyvaleit/nginx@sha256:1cd75c9545c05f8a30d4416b6f113e909213c915a7bd7ab43842d28eacf2d328
Name:           sha256:1cd75c9545c05f8a30d4416b6f113e909213c915a7bd7ab43842d28eacf2d328
Created:        Less than a second ago
Annotations:    image.openshift.io/dockerLayersOrder=ascending
Image Size:     39.95MB in 9 layers
Layers:         37.22MB sha256:6f5424ebd79619fda12f08fa4f611e1fdf38967ebc1a296dc1b403aa019f7b39
                30.23kB sha256:d15444df170ac58f886d8efeed1bf901725cabba200d4670a27e3bf65f403b69
                244B    sha256:e83f073daa67782dba3d35c1cfb6b81f845a3c84ce5b2cbf3a8af45a6dceecbc
                2.688MB sha256:a4d93e4210232a57cc89d4eea1206f7557234be7f705c3f8773b1b445373f09c
                173B    sha256:084adbca264718d53a89618ccfd0adf44dc8b91483b8ef98513637f9c1ba39a3
                171B    sha256:c9cec474c523e8d7ad43b27197e0e52b6b1f37b2e1ca6799c672c221adc07ca9
                193B    sha256:ae2363c534d35ba9eea08627dd59141487cf50b594273a0503004f1225f24d1d
                690B    sha256:6cdd8067e069cab3e18e66b550e7b699d7089fa0696f3e6b2a6c17a16eb2b025
                536B    sha256:1b3f78478ffd32d00784095e54f1dc2b75ad9483443cd4ea0cefc25ea790d170
Image Created:  3 days ago
Author:         NGINX Docker Maintainers "docker-maint@nginx.com"
Arch:           amd64
Command:        nginx -g daemon off;
Working Dir:    <none>
User:           <none>
Exposes Ports:  443/tcp, 80/tcp, 8081/tcp
Docker Labels:  <none>
Environment:    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
                NGINX_VERSION=1.7.9-1~wheezy
Volumes:        /var/cache/nginx

```

This ImageStream has 1 tag **latest** that points to Docker image **sunnyvaleit/nginx:1.7.9-openshift** (from DockerHub)


```console
$ oc get is   
NAME          IMAGE REPOSITORY                                                           TAGS     UPDATED
my-nginx-is   default-route-openshift-image-registry.apps-crc.testing/test/my-nginx-is   latest   24 seconds ago
```

## Create a DeploymentConfig

```console
$ oc apply -f dc.yaml
deploymentconfig.apps.openshift.io/simple-http-server created
```



```console
$ oc get dc 
NAME                 REVISION   DESIRED   CURRENT   TRIGGERED BY
simple-http-server   1          1         1         image(my-nginx-is:latest)
```

The output above showes that a DeploymentConfig has been created using ImageStream **my-nginx-is:latest**.

As you can see, the DeploymentConfig also created a ReplicationController

```console
$ oc get rc 
NAME                   DESIRED   CURRENT   READY   AGE
simple-http-server-1   1         1         1       2m48s
```

Each time a deployment is triggered, whether manually or automatically, a deployer Pod manages the deployment (including scaling down the old ReplicationController, scaling up the new one, and running hooks). The deployment Pod remains for an indefinite amount of time after it completes the deployment in order to retain the logs from the deployment itself.

```console
$ oc get pods
NAME                          READY   STATUS      RESTARTS   AGE
simple-http-server-1-deploy   0/1     Completed   0          3m7s
simple-http-server-1-fbrd4    1/1     Running     0          3m4s
```

Verify that within the Pod, an Nginx v. 1.7.9 is running 

```console
$ oc exec -ti simple-http-server-1-fbrd4 -- nginx  -V
nginx version: nginx/1.7.9
built by gcc 4.7.2 (Debian 4.7.2-5) 
TLS SNI support enabled
configure arguments: --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-mail --with-mail_ssl_module --with-file-aio --with-http_spdy_module --with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-z,relro -Wl,--as-needed' --with-ipv6
```

Now, we are going to modify the ImageStream's **latest** tag to point to a newer version nginx Docker image (ie: 1.19.3)

```console
$ oc tag docker.io/sunnyvaleit/nginx:1.19.3-openshift my-nginx-is:latest
Tag my-nginx-is:latest set to docker.io/sunnyvaleit/nginx:1.19.3-openshift.
```

Describe the ImageStream again to see the new latest tag.

```console
$ oc describe is my-nginx-is 
Name:                   my-nginx-is
Namespace:              test
Created:                7 seconds ago
Labels:                 <none>
Annotations:            openshift.io/image.dockerRepositoryCheck=2023-10-30T14:37:58Z
Image Repository:       default-route-openshift-image-registry.apps-crc.testing/test/my-nginx-is
Image Lookup:           local=false
Unique Images:          2
Tags:                   1

latest
  tagged from docker.io/sunnyvaleit/nginx:1.19.3-openshift

  * docker.io/sunnyvaleit/nginx@sha256:1f7686d02d35bbf88e57b8157b349cc6775fb85ac837ae9410170fade95ce449
      2 seconds ago
    sunnyvaleit/nginx@sha256:1cd75c9545c05f8a30d4416b6f113e909213c915a7bd7ab43842d28eacf2d328
      7 seconds ago
```

The latest tag now points to docker.io/nginx:1.19.3.

As you notice, a new deployer Pod has been created as well as a new nginx Pod (from the ImageStream **latest**)

```console
$ oc get pods    
NAME                          READY   STATUS      RESTARTS   AGE
simple-http-server-1-deploy   0/1     Completed   0          6m29s
simple-http-server-2-deploy   0/1     Completed   0          38s
simple-http-server-2-gt49s    1/1     Running     0          30s
```

To verify that the nginx version in the pod is 1.19.3 (coming from the change of the ImageStream) we can run the command:

```console
$ oc exec -ti simple-http-server-2-gt49s -- nginx  -V 
nginx version: nginx/1.19.3
...
```

Make sure to use the correct Pod name.

As you noticed, the change of **latest** tag on the ImageStream triggered a Pod rollout with the new nginx version.

This happens due to the DeploymentConfig configuration

```yaml
triggers:
  - type: ImageChange
    imageChangeParams:
      automatic: true
      containerNames:
      - simple-http-server
      from:
        kind: ImageStreamTag
        name: my-nginx-is:latest
```

```console
$ oc rollout history dc/simple-http-server  
deploymentconfig.apps.openshift.io/simple-http-server 
REVISION        STATUS          CAUSE
1               Complete        config change
2               Complete        image change
```

```console
$ oc rollout undo dc/simple-http-server --to-revision=1
deploymentconfig.apps.openshift.io/simple-http-server rolled back
```

```console
$ oc get rc                                            
NAME                   DESIRED   CURRENT   READY   AGE
simple-http-server-1   0         0         0       11m
simple-http-server-2   0         0         0       6m14s
simple-http-server-3   1         1         1       19s
```

## Cleanup


```console
$ oc delete -f .
deploymentconfig.apps.openshift.io "simple-http-server" deleted
```

```console
$ oc delete is my-nginx-is
imagestream.image.openshift.io "my-nginx-is" deleted
```