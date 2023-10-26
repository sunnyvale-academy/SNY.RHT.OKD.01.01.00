# Provision the environment using CodeReady Containers

Download CodeReady Containers (now renamed to OpenShift Local) and the pull-secret file [here](https://developers.redhat.com/products/codeready-containers/overview).

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

Configure VM memory (if needed)

RAM in MB (default 8192MB)
```console
$ crc config set memory 12500
```

or, if you have enough physical memory and cpu, you can reserve even more resources to CRC:

```console
$ crc config set memory 14336
```

CPUS (default 4)
```console
$ crc config set cpus 8
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
? Image pull secret [? for help] ******************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************

INFO Loading bundle: crc_hyperkit_4.5.14.crcbundle ... 
INFO Checking size of the disk image /Users/denismaggiorotto/.crc/cache/crc_hyperkit_4.5.14/crc.qcow2 ... 
INFO Creating CodeReady Containers VM for OpenShift 4.5.14... 
INFO CodeReady Containers VM is running           
INFO Generating new SSH Key pair ...              
INFO Copying kubeconfig file to instance dir ...  
INFO Starting network time synchronization in CodeReady Containers VM 
INFO Verifying validity of the cluster certificates ... 
INFO Network restart not needed                   
INFO Check internal and public DNS query ...      
INFO Check DNS query from host ...                
INFO Starting OpenShift kubelet service           
INFO Configuring cluster for first start          
INFO Adding user's pull secret ...                
INFO Updating cluster ID ...                      
INFO Starting OpenShift cluster ... [waiting 3m]  
INFO Updating kubeconfig                          
WARN The cluster might report a degraded or error state. This is expected since several operators have been disabled to lower the resource usage. For more information, please consult the documentation 
Started the OpenShift cluster

To access the cluster, first set up your environment by following 'crc oc-env' instructions.
Then you can access it by running 'oc login -u developer -p developer https://api.crc.testing:6443'.
To login as an admin, run 'oc login -u kubeadmin -p dpDFV-xamBW-kKAk3-Fi6Lg https://api.crc.testing:6443'.
To access the cluster, first set up your environment by following 'crc oc-env' instructions.

You can now run 'crc console' and use these credentials to access the OpenShift web console.
```

If something went wrong with DNS resolution (a WARN message came out from the start outout), stop the cluster using `crc stop`the start it again with `crc start -n 8.8.8.8`.

To verify the cluster status:

```console
$ crc status
CRC VM:          Running
OpenShift:       Running (v4.5.7)
Disk Usage:      15.88GB of 32.72GB (Inside the CRC VM)
Cache Usage:     12.8GB
Cache Directory: /Users/myuser/.crc/cache
```

To get started with CRC, please have a look of the following [documentation](https://access.redhat.com/documentation/en-us/red_hat_codeready_containers/)

When done, stop the cluster using:

```console
$  crc stop 
Stopping the OpenShift cluster, this may take a few minutes...
Stopped the OpenShift cluster
```

