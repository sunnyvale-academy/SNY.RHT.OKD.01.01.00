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
$ oc import-image my-nginx-is:latest --from=nginx:1.7.9 --confirm  
imagestream.image.openshift.io/my-nginx-is imported

Name:                   my-nginx-is
Namespace:              test
Created:                About a minute ago
Labels:                 <none>
Annotations:            kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"image.openshift.io/v1","kind":"ImageStream","metadata":{"annotations":{"openshift.io/image.dockerRepositoryCheck":"2020-10-28T00:24:13Z"},"creationTimestamp":"2020-10-28T00:24:13Z","generation":2,"name":"my-nginx-is","namespace":"test","resourceVersion":"417238","selfLink":"/apis/image.openshift.io/v1/namespaces/test/imagestreams/my-nginx-is","uid":"74ca49af-c700-4b77-bfab-b40f6ccc4f10"},"spec":{"lookupPolicy":{"local":false},"tags":[{"annotations":null,"from":{"kind":"DockerImage","name":"nginx:1.7.9"},"generation":1,"importPolicy":{},"name":"1.7.9","referencePolicy":{"type":"Source"}}]},"status":{"dockerImageRepository":"image-registry.openshift-image-registry.svc:5000/test/my-nginx-is","publicDockerImageRepository":"default-route-openshift-image-registry.apps-crc.testing/test/my-nginx-is","tags":[{"items":[{"created":"2020-10-28T00:24:13Z","dockerImageReference":"nginx@sha256:e3456c851a152494c3e4ff5fcc26f240206abac0c9d794affb40e0714846c451","generation":1,"image":"sha256:e3456c851a152494c3e4ff5fcc26f240206abac0c9d794affb40e0714846c451"}],"tag":"1.7.9"},{"items":[{"created":"2020-10-28T00:24:23Z","dockerImageReference":"nginx@sha256:e3456c851a152494c3e4ff5fcc26f240206abac0c9d794affb40e0714846c451","generation":2,"image":"sha256:e3456c851a152494c3e4ff5fcc26f240206abac0c9d794affb40e0714846c451"}],"tag":"latest"}]}}

                        openshift.io/image.dockerRepositoryCheck=2020-10-28T00:28:32Z
Image Repository:       default-route-openshift-image-registry.apps-crc.testing/test/my-nginx-is
Image Lookup:           local=false
Unique Images:          1
Tags:                   2

latest
  tagged from nginx:1.7.9

  * nginx@sha256:e3456c851a152494c3e4ff5fcc26f240206abac0c9d794affb40e0714846c451
      Less than a second ago

1.7.9
  tagged from nginx:1.7.9

  * nginx@sha256:e3456c851a152494c3e4ff5fcc26f240206abac0c9d794affb40e0714846c451
      About a minute ago

Image Name:     my-nginx-is:1.7.9
Docker Image:   nginx@sha256:e3456c851a152494c3e4ff5fcc26f240206abac0c9d794affb40e0714846c451
Name:           sha256:e3456c851a152494c3e4ff5fcc26f240206abac0c9d794affb40e0714846c451
Created:        Less than a second ago
Annotations:    image.openshift.io/dockerLayersOrder=ascending
Image Size:     91.66MB in 14 layers
Layers:         0B      sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
                85.01MB sha256:6f5424ebd79619fda12f08fa4f611e1fdf38967ebc1a296dc1b403aa019f7b39
                0B      sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
                0B      sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
                58.45kB sha256:d15444df170ac58f886d8efeed1bf901725cabba200d4670a27e3bf65f403b69
                211B    sha256:e83f073daa67782dba3d35c1cfb6b81f845a3c84ce5b2cbf3a8af45a6dceecbc
                0B      sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
                6.591MB sha256:a4d93e4210232a57cc89d4eea1206f7557234be7f705c3f8773b1b445373f09c
                11B     sha256:084adbca264718d53a89618ccfd0adf44dc8b91483b8ef98513637f9c1ba39a3
                11B     sha256:c9cec474c523e8d7ad43b27197e0e52b6b1f37b2e1ca6799c672c221adc07ca9
                0B      sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
                0B      sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
                0B      sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
                0B      sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
Image Created:  5 years ago
Author:         NGINX Docker Maintainers "docker-maint@nginx.com"
Arch:           amd64
Command:        nginx -g daemon off;
Working Dir:    <none>
User:           <none>
Exposes Ports:  443/tcp, 80/tcp
Docker Labels:  <none>
Environment:    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
                NGINX_VERSION=1.7.9-1~wheezy
Volumes:        /var/cache/nginx
```

This ImageStream has 1 tag **latest** that points to Docker image **nginx:1.7.9** (from DockerHub)


```console
$ oc get is   
NAME          IMAGE REPOSITORY                                                           TAGS     UPDATED
my-nginx-is   default-route-openshift-image-registry.apps-crc.testing/test/my-nginx-is   latest   5 seconds ago
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

Now, we are going to modify the ImageStream's **latest** tag to point to a newer version nginx Docker image (ie: 1.19.3)

```console
$ oc tag docker.io/nginx:1.19.3 my-nginx-is:latest
Tag my-nginx-is:latest set to docker.io/nginx:1.19.3.
```

In this case, as you notice a new deployer Pod has been created as well as a new nginx Pod (from the ImageStream **latest**)

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

## Cleanup


```console
$ oc delete -f .
deploymentconfig.apps.openshift.io "simple-http-server" deleted
```

```console
$ oc delete is my-nginx-is
imagestream.image.openshift.io "my-nginx-is" deleted
```