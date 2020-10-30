# Project

![OpenShift](https://img.shields.io/badge/OpenShift-informational?logo=Red%20Hat%20Open%20Shift&color=black&logoColor=red&style=for-the-badge&logoWidth=30)

## Prerequisites

Having completed the following labs:

- [00 - Prerequisites](../00-Prerequisites/README.md)
- [02 - Provision the environment](../02-Provision_the_environment/README.md)
- [03 - OKD login](../03-OKD_login/README.md) (using **kubeadmin** user)

## Create a new project

Please make sure to be logged in as **kubeadmin** user with **oc** client.

```console
$ oc whoami
kube:admin
```

If the output obtained with the command above is not **kube:admin**, review the lab [02 - OKD login](../02-OKD_login/README.md) and login as using **kubeadmin** user.

Create a new project:

```console
$ oc new-project test     
Now using project "test" on server "https://api.crc.testing:6443".

You can add applications to this project with the 'new-app' command. For example, try:

    oc new-app ruby~https://github.com/sclorg/ruby-ex.git

to build a new example application in Ruby. Or use kubectl to deploy a simple Kubernetes application:

    kubectl create deployment hello-node --image=gcr.io/hello-minikube-zero-install/hello-node
```

Now a couple of roles to the "developer" user

```console
$ oc adm policy add-role-to-user admin developer
clusterrole.rbac.authorization.k8s.io/admin added: "developer"
```

```console
$ oc adm policy add-cluster-role-to-user cluster-admin developer
clusterrole.rbac.authorization.k8s.io/cluster-admin added: "developer"
```

To get a list of the users who have access to a project, and using what role, just run:

```console
$ oc get rolebindings -o wide
NAME                    ROLE                               AGE     USERS        GROUPS                        SERVICEACCOUNTS
admin                   ClusterRole/admin                  2m54s   kube:admin                                 
admin-0                 ClusterRole/admin                  83s     developer                                  
system:deployers        ClusterRole/system:deployer        2m53s                                              test/deployer
system:image-builders   ClusterRole/system:image-builder   2m54s                                              test/builder
system:image-pullers    ClusterRole/system:image-puller    2m54s                system:serviceaccounts:test   
```

In order to execute the next labs, apply all the following policies to the newly created test project: 

```console
oc adm policy add-scc-to-user anyuid system:serviceaccount:test:default
oc adm policy add-role-to-user system:controller:persistent-volume-binder developer
```