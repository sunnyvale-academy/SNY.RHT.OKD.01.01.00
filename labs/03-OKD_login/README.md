# Login to the environment

## Get credentials

```console
$ crc console --credentials       
To login as a regular user, run 'oc login -u developer -p developer https://api.crc.testing:6443'.
To login as an admin, run 'oc login -u kubeadmin -p dpDFV-xamBW-kKAk3-Fi6Lg https://api.crc.testing:6443'
```

## Web Console

To open the CRC console:

```console
$ crc console
```

A browser window opens asking you to authenticate.

### As user

Choose the **htpasswd_provider** option in the OpenShift web console.

Log in as **developer** user with password **developer** to login as user.

### As administrator

Choose the **kube:admin** option in the OpenShift web console.

Log in as **kubeadmin** user with the password provided at the end of the `crc start` command to login as administrator.

## CLI 

### As user

```console
$ oc login -u developer -p developer https://api.crc.testing:6443
```


### As administrator
```console
$ oc login -u kubeadmin -p dpDFV-xamBW-kKAk3-Fi6Lg https://api.crc.testing:6443
Login successful.

You have access to 57 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "default".
```
