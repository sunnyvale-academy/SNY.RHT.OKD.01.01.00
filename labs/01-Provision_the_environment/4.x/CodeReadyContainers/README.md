## Provision the environment using CodeReady Containers

Download CodeReady Containers (CRC) and the pull-request file [here](https://developers.redhat.com/products/codeready-containers/overview).

You'll be asked for a RedHat account in order to download CRC.

When done, put the crc binary into the PATH environment variable.

Setup the CRC VM

```console
$ crc setup
INFO Checking if oc binary is cached
INFO Caching oc binary
INFO Checking if podman remote binary is cached
INFO Checking if goodhosts binary is cached
INFO Caching goodhosts binary
INFO Will use root access: change ownership of /Users/myuser/.crc/bin/goodhosts
Password:
INFO Will use root access: set suid for /Users/myuser/.crc/bin/goodhosts
INFO Checking if CRC bundle is cached in '$HOME/.crc'
INFO Unpacking bundle from the CRC binary
INFO Checking minimum RAM requirements
INFO Checking if running as non-root
INFO Checking if HyperKit is installed
INFO Setting up virtualization with HyperKit
INFO Will use root access: change ownership of /Users/myuser/.crc/bin/hyperkit
INFO Will use root access: set suid for /Users/myuser/.crc/bin/hyperkit
INFO Checking if crc-driver-hyperkit is installed
INFO Installing crc-machine-hyperkit
INFO Will use root access: change ownership of /Users/myuser/.crc/bin/crc-driver-hyperkit
INFO Will use root access: set suid for /Users/myuser/.crc/bin/crc-driver-hyperkit
INFO Checking file permissions for /etc/hosts
INFO Checking file permissions for /etc/resolver/testing
INFO Setting file permissions for /etc/resolver/testing
INFO Will use root access: create file /etc/resolver/testing
INFO Will use root access: change ownership of /etc/resolver/testing
Setup is complete, you can now run 'crc start' to start the OpenShift cluster
```

Now start the VM, be sure to paste the content of pull-secret file when prompted.

```console
$ crc start
INFO Checking if oc binary is cached
INFO Checking if podman remote binary is cached
INFO Checking if goodhosts binary is cached
INFO Checking minimum RAM requirements
INFO Checking if running as non-root
INFO Checking if HyperKit is installed
INFO Checking if crc-driver-hyperkit is installed
INFO Checking file permissions for /etc/hosts
INFO Checking file permissions for /etc/resolver/testing
? Image pull secret [? for help] *********************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************INFO Extracting bundle: crc_hyperkit_4.5.7.crcbundle ... *********************************************************************************crc.qcow2: 9.68 GiB / 9.68 GiB [-------------------------------------------------------------------------------------------------] 100.00%INFO Checking size of the disk image /Users/myuser/.crc/cache/crc_hyperkit_4.5.7/crc.qcow2 ... *********************************INFO Creating CodeReady Containers VM for OpenShift 4.5.7... *****************************************************************************INFO CodeReady Containers VM is running           ****************************************************************************************INFO Generating new SSH Key pair ...              ****************************************************************************************INFO Copying kubeconfig file to instance dir ...  ****************************************************************************************INFO Starting network time synchronization in CodeReady Containers VM ********************************************************************INFO Verifying validity of the cluster certificates ... **********************************************************************************INFO Restarting the host network                  ****************************************************************************************INFO Check internal and public DNS query ...      **********************************************************************************************************************************************************************INFO Check DNS query from host ...                ****************************************************************************************INFO Starting OpenShift kubelet service           *
INFO Configuring cluster for first start
INFO Adding user's pull secret ...
INFO Updating cluster ID ...
INFO Starting OpenShift cluster ... [waiting 3m]
INFO Updating kubeconfig
INFO
INFO To access the cluster, first set up your environment by following 'crc oc-env' instructions
INFO Then you can access it by running 'oc login -u developer -p developer https://api.crc.testing:6443'
INFO To login as an admin, run 'oc login -u kubeadmin -p ILWgF-VfgcQ-p6mJ4-Jztez https://api.crc.testing:6443'
INFO
INFO You can now run 'crc console' and use these credentials to access the OpenShift web console
Started the OpenShift cluster
```

To open the CRC console

```console
$ crc console
```

A browser window opens asking you to authenticate.

Choose the **htpasswd_provider** option in the OpenShift web console.

Log in as **developer** user with password **developer**

To get started with CRC, please have a look of the following [documentation](https://access.redhat.com/documentation/en-us/red_hat_codeready_containers/1.15/)



