# Helm

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

This lab works form Helm version 3 onwards.

To check the Helm version type:

```console
$ helm version
version.BuildInfo{Version:"v3.0.1", GitCommit:"7c22ef9ce89e0ebeb7125ba2ebf7d421f3e82ffa", GitTreeState:"clean", GoVersion:"go1.13.4"}
```


## Helm (CLI) installation

On *nix

```console
$ curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

On MacOS (using Homebrew)

```console
$ brew install kubernetes-helm
```

On Windows (using Chocolatey)

```console
$ choco install kubernetes-helm
```

## Deployment prerequisites

You need to be logged in as kubeadmin in order to deploy this example:

```console
$ oc login -u kubeadmin -p \<KUBEADMIN PASSWORD\> https://api.crc.testing:6443
Login successful.
```

```console
$ oc project test
Already on project "test" on server "https://api.crc.testing:6443".
```


## Deploy an example app (HashiCorp Vault) using Helm

We are going to install HashiCorp Vault on OpenShift using Helm.

Before to begin, add the HashiCorp helm repo

```console
$ helm repo add hashicorp https://helm.releases.hashicorp.com
"hashicorp" has been added to your repositories
```

then update repo indexes

```console
$ helm repo update                                      
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "hashicorp" chart repository
Update Complete. ⎈Happy Helming!⎈
```

Now we are ready to install Vault


```console
$ helm install vault hashicorp/vault --values values.yaml
NAME: vault
LAST DEPLOYED: Sat Nov 18 10:56:14 2023
NAMESPACE: test
STATUS: deployed
REVISION: 1
NOTES:
Thank you for installing HashiCorp Vault!

Now that you have deployed Vault, you should look over the docs on using
Vault with Kubernetes available here:

https://developer.hashicorp.com/vault/docs


Your release is named vault. To learn more about the release, try:

  $ helm status vault
  $ helm get manifest vault
```

Let's see what has been created

```console
$ oc get all -n test
Warning: apps.openshift.io/v1 DeploymentConfig is deprecated in v4.14+, unavailable in v4.10000+
NAME                                        READY   STATUS    RESTARTS   AGE
pod/vault-0                                 1/1     Running   0          3m57s
pod/vault-agent-injector-6f66b5b99d-9g72s   1/1     Running   0          3m57s

NAME                               TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)             AGE
service/vault                      ClusterIP   10.217.4.62    <none>        8200/TCP,8201/TCP   3m57s
service/vault-agent-injector-svc   ClusterIP   10.217.5.13    <none>        443/TCP             3m57s
service/vault-internal             ClusterIP   None           <none>        8200/TCP,8201/TCP   3m57s

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/vault-agent-injector   1/1     1            1           3m57s

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/vault-agent-injector-6f66b5b99d   1         1         1       3m57s

NAME                             READY   AGE
statefulset.apps/vault           1/1     3m57s
```

To delete a release (thus remove anything that has been created with the Vault chart), just type:

```console
$ helm delete vault -n test
release "vault" uninstalled
```