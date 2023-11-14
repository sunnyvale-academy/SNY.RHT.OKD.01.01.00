# Buinding Nginx images to be run on OpenShift



Nginx 1.7.9

```console
$ docker build 
    -f Dockerfile-1.7.9-openshift 
    -t nginx:1.7.9-openshift 
    .
```

This image is made available to you at docker.io/sunnyvaleit/nginx:1.7.9-openshift (arm64 version)


Nginx 1.19.3

```console
$ docker build 
    -f Dockerfile-1.19.3-openshift 
    -t nginx:1.19.3-openshift 
    .
```

This image is made available to you at docker.io/sunnyvaleit/nginx:1.19.3-openshift (arm64 version)
