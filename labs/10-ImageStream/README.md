# ImageStream

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

## Create an ImageStream

Create an ImageStream using `oc` command:

```console
$ oc import-image python:3.5 --from=centos/python-35-centos7 --confirm
imagestream.image.openshift.io/python imported

Name:                   python
Namespace:              test
Created:                Less than a second ago
Labels:                 <none>
Annotations:            openshift.io/image.dockerRepositoryCheck=2020-10-27T20:06:36Z
Image Repository:       image-registry.openshift-image-registry.svc:5000/test/python
Image Lookup:           local=false
Unique Images:          1
Tags:                   1

3.5
  tagged from centos/python-35-centos7

  * centos/python-35-centos7@sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870
      Less than a second ago

Image Name:     python:latest
Docker Image:   centos/python-35-centos7@sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870
Name:           sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870
Created:        Less than a second ago
Annotations:    image.openshift.io/dockerLayersOrder=ascending
Image Size:     227.4MB in 9 layers
Layers:         75.4MB  sha256:8ba884070f611d31cb2c42eddb691319dc9facf5e0ec67672fcfa135181ab3df
                9.674MB sha256:c3dca185eb1482e83381d99881430ebc179e91f0969bc905207cd1e2312e5b57
                4.832kB sha256:ee720ba20823ba4560916cf32bc06c5e31c230cb76f641be4a5fbfc7754d7574
                180.9kB sha256:497ef6ea0fac8097af3363a9b9032f0948098a9fa2b9002eb51ac65f2ed29cf6
                90.4MB  sha256:ebf1fb961f612b70f32c7d9184c8b3e06b9f427dff8c77385a489a4f2fbfac12
                48.57MB sha256:1934b13ec89c18c185e990236913c41f74ad62f27009b3bea1f6f8dbc21a83cc
                2.842kB sha256:b4218d63771a141e642aedd02f47959d028b712c6c5831fa80c7cf529a5969cc
                4.501kB sha256:dd012b8e01626cf488d6f2047f58c5861cc87d3adea4e8d685ddedbe07545101
                3.113MB sha256:1d332f8ae1555f545497a6e6ac7d5492dc7f73b781efe658afec8593d92f80dc
Image Created:  19 months ago
Author:         <none>
Arch:           amd64
Entrypoint:     container-entrypoint
Command:        /bin/sh -c $STI_SCRIPTS_PATH/usage
Working Dir:    /opt/app-root/src
User:           1001
Exposes Ports:  8080/tcp
Docker Labels:  com.redhat.component=python35-container
                description=Python 3.5 available as container is a base platform for building and running various Python 3.5 applications and frameworks. Python is an easy to learn, powerful programming language. It has efficient high-level data structures and a simple but effective approach to object-oriented programming. Python's elegant syntax and dynamic typing, together with its interpreted nature, make it an ideal language for scripting and rapid application development in many areas on most platforms.
                io.k8s.description=Python 3.5 available as container is a base platform for building and running various Python 3.5 applications and frameworks. Python is an easy to learn, powerful programming language. It has efficient high-level data structures and a simple but effective approach to object-oriented programming. Python's elegant syntax and dynamic typing, together with its interpreted nature, make it an ideal language for scripting and rapid application development in many areas on most platforms.
                io.k8s.display-name=Python 3.5
                io.openshift.builder-version="b8402db"
                io.openshift.expose-services=8080:http
                io.openshift.s2i.scripts-url=image:///usr/libexec/s2i
                io.openshift.tags=builder,python,python35,python-35,rh-python35
                io.s2i.scripts-url=image:///usr/libexec/s2i
                maintainer=SoftwareCollections.org <sclorg@redhat.com>
                name=centos/python-35-centos7
                org.label-schema.build-date=20190305
                org.label-schema.license=GPLv2
                org.label-schema.name=CentOS Base Image
                org.label-schema.schema-version=1.0
                org.label-schema.vendor=CentOS
                summary=Platform for building and running Python 3.5 applications
                usage=s2i build https://github.com/sclorg/s2i-python-container.git --context-dir=3.5/test/setup-test-app/ centos/python-35-centos7 python-sample-app
                version=3.5
Environment:    PATH=/opt/app-root/src/.local/bin/:/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
                SUMMARY=Platform for building and running Python 3.5 applications
                DESCRIPTION=Python 3.5 available as container is a base platform for building and running various Python 3.5 applications and frameworks. Python is an easy to learn, powerful programming language. It has efficient high-level data structures and a simple but effective approach to object-oriented programming. Python's elegant syntax and dynamic typing, together with its interpreted nature, make it an ideal language for scripting and rapid application development in many areas on most platforms.
                STI_SCRIPTS_URL=image:///usr/libexec/s2i
                STI_SCRIPTS_PATH=/usr/libexec/s2i
                APP_ROOT=/opt/app-root
                HOME=/opt/app-root/src
                PLATFORM=el7
                BASH_ENV=/opt/app-root/etc/scl_enable
                ENV=/opt/app-root/etc/scl_enable
                PROMPT_COMMAND=. /opt/app-root/etc/scl_enable
                NODEJS_SCL=rh-nodejs10
                PYTHON_VERSION=3.5
                PYTHONUNBUFFERED=1
                PYTHONIOENCODING=UTF-8
                LC_ALL=en_US.UTF-8
                LANG=en_US.UTF-8
                PIP_NO_CACHE_DIR=off
```

- python:3.5 - python is the new ImageStream that will be created as a result of this invocation. Additionally we are explicitly pointing that the imported image will be kept under the 3.5 ImageStream Tag of that ImageStream. If no tag part is specified the command will use latest.
- --from=centos/python-35-centos7 - states what external image the ImageStream Tag will point to.
- --confirm - informs the system that the python ImageStream should be created, if this is omitted and there is no python ImageStream, you will be presented with an error message.

List the ImageStream resources

```console
$ oc get is
NAME     IMAGE REPOSITORY                                                      TAGS   UPDATED
python   default-route-openshift-image-registry.apps-crc.testing/test/python   3.5    Less than a second ago
```

Describe the ImageStream just created

```console
$ oc describe is/python

Name:                   python
Namespace:              test
Created:                About a minute ago
Labels:                 <none>
Annotations:            kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"image.openshift.io/v1","kind":"ImageStream","metadata":{"annotations":{"openshift.io/image.dockerRepositoryCheck":"2020-10-27T20:06:36Z"},"creationTimestamp":"2020-10-27T20:06:36Z","generation":1,"name":"python","namespace":"test","resourceVersion":"372361","selfLink":"/apis/image.openshift.io/v1/namespaces/test/imagestreams/python","uid":"ca34b75f-419d-4911-a6a8-46c83ccfbae6"},"spec":{"lookupPolicy":{"local":false},"tags":[{"annotations":null,"from":{"kind":"DockerImage","name":"centos/python-35-centos7"},"generation":1,"importPolicy":{},"name":"3.5","referencePolicy":{"type":"Source"}}]},"status":{"dockerImageRepository":"image-registry.openshift-image-registry.svc:5000/test/python","publicDockerImageRepository":"default-route-openshift-image-registry.apps-crc.testing/test/python","tags":[{"items":[{"created":"2020-10-27T20:06:36Z","dockerImageReference":"centos/python-35-centos7@sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870","generation":1,"image":"sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870"}],"tag":"3.5"}]}}

                        openshift.io/image.dockerRepositoryCheck=2020-10-27T20:10:45Z
Image Repository:       default-route-openshift-image-registry.apps-crc.testing/test/python
Image Lookup:           local=false
Unique Images:          1
Tags:                   1

3.5
  tagged from centos/python-35-centos7

  * centos/python-35-centos7@sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870
      About a minute ago
```

As you can see, this ImageStream has only 1 tag in it.

## Add more tags to the current ImageStream 

To add a **latest** tag that points to one of the existing tags, you can use the `oc tag` command (self reference)


```console
$ oc tag python:3.5 python:latest
Tag python:latest set to python@sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870.
```



```console
$ oc describe is/python
Name:                   python
Namespace:              test
Created:                2 hours ago
Labels:                 <none>
Annotations:            kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"image.openshift.io/v1","kind":"ImageStream","metadata":{"annotations":{"openshift.io/image.dockerRepositoryCheck":"2020-10-27T20:06:36Z"},"creationTimestamp":"2020-10-27T20:06:36Z","generation":1,"name":"python","namespace":"test","resourceVersion":"372361","selfLink":"/apis/image.openshift.io/v1/namespaces/test/imagestreams/python","uid":"ca34b75f-419d-4911-a6a8-46c83ccfbae6"},"spec":{"lookupPolicy":{"local":false},"tags":[{"annotations":null,"from":{"kind":"DockerImage","name":"centos/python-35-centos7"},"generation":1,"importPolicy":{},"name":"3.5","referencePolicy":{"type":"Source"}}]},"status":{"dockerImageRepository":"image-registry.openshift-image-registry.svc:5000/test/python","publicDockerImageRepository":"default-route-openshift-image-registry.apps-crc.testing/test/python","tags":[{"items":[{"created":"2020-10-27T20:06:36Z","dockerImageReference":"centos/python-35-centos7@sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870","generation":1,"image":"sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870"}],"tag":"3.5"}]}}

                        openshift.io/image.dockerRepositoryCheck=2020-10-27T20:10:45Z
Image Repository:       default-route-openshift-image-registry.apps-crc.testing/test/python
Image Lookup:           local=false
Unique Images:          1
Tags:                   2

latest
  tagged from python@sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870

  * centos/python-35-centos7@sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870
      27 seconds ago

3.5
  tagged from centos/python-35-centos7

  * centos/python-35-centos7@sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870
      2 hours ago
```

The image python:latest now appears within the ImageStream and as you can see, it references the same image **centos/python-35-centos7@sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870**

## Add a tag poiting to an external image

All tag-related operations are performed using `oc tag` command, and adding tags pointing to internal or external images is not any different:

```
$ oc tag docker.io/python:3.6.0 python:3.6
Tag python:3.6 set to docker.io/python:3.6.0.
```

This command maps the docker.io/python:3.6.0 image to the 3.6 tag in our python ImageStream. In the case the external image is secured, you will need to create a Secret with credentials for accessing that registry.

Describe the result:

```
$ oc describe is python
Name:                   python
Namespace:              test
Created:                2 hours ago
Labels:                 <none>
Annotations:            kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"image.openshift.io/v1","kind":"ImageStream","metadata":{"annotations":{"openshift.io/image.dockerRepositoryCheck":"2020-10-27T20:06:36Z"},"creationTimestamp":"2020-10-27T20:06:36Z","generation":1,"name":"python","namespace":"test","resourceVersion":"372361","selfLink":"/apis/image.openshift.io/v1/namespaces/test/imagestreams/python","uid":"ca34b75f-419d-4911-a6a8-46c83ccfbae6"},"spec":{"lookupPolicy":{"local":false},"tags":[{"annotations":null,"from":{"kind":"DockerImage","name":"centos/python-35-centos7"},"generation":1,"importPolicy":{},"name":"3.5","referencePolicy":{"type":"Source"}}]},"status":{"dockerImageRepository":"image-registry.openshift-image-registry.svc:5000/test/python","publicDockerImageRepository":"default-route-openshift-image-registry.apps-crc.testing/test/python","tags":[{"items":[{"created":"2020-10-27T20:06:36Z","dockerImageReference":"centos/python-35-centos7@sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870","generation":1,"image":"sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870"}],"tag":"3.5"}]}}

                        openshift.io/image.dockerRepositoryCheck=2020-10-27T22:09:17Z
Image Repository:       default-route-openshift-image-registry.apps-crc.testing/test/python
Image Lookup:           local=false
Unique Images:          2
Tags:                   3

latest
  tagged from python@sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870

  * centos/python-35-centos7@sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870
      9 minutes ago

3.6
  tagged from docker.io/python:3.6.0

  * docker.io/python@sha256:438208801c4801efbf8b0e318ff6548460b27bd1fbcb7bb188273d13871ab43f
      About a minute ago

3.5
  tagged from centos/python-35-centos7

  * centos/python-35-centos7@sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870
      2 hours ago
```

As you can see, ImageStream tag **3.6** points to an external image (external because the name includes the registry URL docker.io)

## Update a current tag

We have just updated our ImageStream with a new tag and now we want to update the latest tag to reflect the newer 3.6 tag in our ImageStream. Not surprisingly, we are going to use `oc tag` once again:

```console
$ oc tag python:3.6 python:latest
Tag python:latest set to python@sha256:438208801c4801efbf8b0e318ff6548460b27bd1fbcb7bb188273d13871ab43f.
```

## Periodically import tags

When we are working with an external registry, we would like to be able to periodically re-import the image to get latest security updates, etc. To do so we will use a `--scheduled` flag for the `oc tag` command like so:

```console
$ oc tag docker.io/python:3.6.0 python:3.6 --scheduled
Tag python:3.6 set to import docker.io/python:3.6.0 periodically.
```

This will inform the system that this particular ImageStream Tag should be periodically checked for updates. Currently, this period is a cluster-wide setting, and by default, it is set to 15 minutes.

Only an ImageStream Tag pointing to an external docker registry can be periodically checked for updates.

To remove the periodical check, re-run above command but omit the `--scheduled` flag. This will reset its behavior to default.

## Remove a tag from ImageStream

Eventually, you will want to remove old tags from your ImageStream, and yet again we are going to use `oc tag` for that particular use case:

```console
$ oc tag -d python:3.5
Deleted tag test/python:3.5.
```

We just removed the 3.5 from the ImageStream, to make sure of it, just describe the ImageStream one more time:

```console
$ oc describe is python
Name:                   python
Namespace:              test
Created:                2 hours ago
Labels:                 <none>
Annotations:            kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"image.openshift.io/v1","kind":"ImageStream","metadata":{"annotations":{"openshift.io/image.dockerRepositoryCheck":"2020-10-27T20:06:36Z"},"creationTimestamp":"2020-10-27T20:06:36Z","generation":1,"name":"python","namespace":"test","resourceVersion":"372361","selfLink":"/apis/image.openshift.io/v1/namespaces/test/imagestreams/python","uid":"ca34b75f-419d-4911-a6a8-46c83ccfbae6"},"spec":{"lookupPolicy":{"local":false},"tags":[{"annotations":null,"from":{"kind":"DockerImage","name":"centos/python-35-centos7"},"generation":1,"importPolicy":{},"name":"3.5","referencePolicy":{"type":"Source"}}]},"status":{"dockerImageRepository":"image-registry.openshift-image-registry.svc:5000/test/python","publicDockerImageRepository":"default-route-openshift-image-registry.apps-crc.testing/test/python","tags":[{"items":[{"created":"2020-10-27T20:06:36Z","dockerImageReference":"centos/python-35-centos7@sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870","generation":1,"image":"sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870"}],"tag":"3.5"}]}}

                        openshift.io/image.dockerRepositoryCheck=2020-10-27T22:19:22Z
Image Repository:       default-route-openshift-image-registry.apps-crc.testing/test/python
Image Lookup:           local=false
Unique Images:          2
Tags:                   2

latest
  tagged from python@sha256:438208801c4801efbf8b0e318ff6548460b27bd1fbcb7bb188273d13871ab43f

  * docker.io/python@sha256:438208801c4801efbf8b0e318ff6548460b27bd1fbcb7bb188273d13871ab43f
      4 minutes ago
    centos/python-35-centos7@sha256:d2018907a8ffa94644fccc8e3821a0945c600a16337c11c1a761e86159d69870
      20 minutes ago

3.6
  updates automatically from registry docker.io/python:3.6.0

  * docker.io/python@sha256:438208801c4801efbf8b0e318ff6548460b27bd1fbcb7bb188273d13871ab43f
      12 minutes ago
```

The last output showes us that:

- ImageStream tag **latest** points to **docker.io/python** image
- ImageStream tag 3.6 points to **docker.io/python** image

## Remove the ImageStream

```console
$ oc delete is python  
imagestream.image.openshift.io "python" deleted
```