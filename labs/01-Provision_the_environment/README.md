
## Provision the environment

```console
$ vagrant up
```

## Open Web Console

In browser of your host, open the following page: https://master.example.com:8443/ and you should see **OpenShift Web Console** login page. The default login account is **admin/handhand**

## Cluster Admin role

To become Cluster Admin, login into the master node and run the following command as root

```console
$ vagrant ssh
[vagrant@master vagrant]$ sudo su
[root@master vagrant]# oc adm policy add-cluster-role-to-user cluster-admin admin --as=system:admin    
cluster role "cluster-admin" added: "admin"
```