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

We are going to install a Kafka cluster (3 pods for Kafka + 3 pods for Zookeeper) to show how Helm simplifies complex architecture  installation.

## Deploy a sample app using Helm

Let's inspect the initial repo/s configured on Helm.

```console
$ helm repo list
NAME            URL                                             
stable          https://kubernetes-charts.storage.googleapis.com
```

Sometimes, Charts are available on repos not known by default by Helm, so we have to add a new one:

```console
$ helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/ 
"confluentinc" has been added to your repositories
```

Update the repos

```console
$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "confluentinc" chart repository
...Successfully got an update from the "stable" chart repository
Update Complete.
```

I provided to you a [values.yaml](values.yaml) file with some variable overrides:

```yaml
cp-schema-registry:
  enabled: false
cp-kafka-rest:
  enabled: false
cp-kafka-connect:
  enabled: false
cp-zookeeper:
  enabled: true
  servers: 3
  persistence:
    enabled: true
    #dataDirStorageClass: "nfs-dynamic"
    #dataLogDirStorageClass: "nfs-dynamic"
cp-ksql-server:
  enabled: false
cp-kafka:
  enabled: true
  brokers: 3
  persistence:
    enabled: true
    #storageClass: "nfs-dynamic"
```

This values.yaml file will be used when installing the chart.

```console
$ helm install my-kafka --values=values.yaml confluentinc/cp-helm-charts
NAME: my-kafka
LAST DEPLOYED: Fri Oct 30 01:07:55 2020
NAMESPACE: test
STATUS: deployed
REVISION: 1
NOTES:
## ------------------------------------------------------
## Zookeeper
## ------------------------------------------------------
Connection string for Confluent Kafka:
  my-kafka-cp-zookeeper-0.my-kafka-cp-zookeeper-headless:2181,my-kafka-cp-zookeeper-1.my-kafka-cp-zookeeper-headless:2181,...

To connect from a client pod:

1. Deploy a zookeeper client pod with configuration:

    apiVersion: v1
    kind: Pod
    metadata:
      name: zookeeper-client
      namespace: test
    spec:
      containers:
      - name: zookeeper-client
        image: confluentinc/cp-zookeeper:4.1.2-1
        command:
          - sh
          - -c
          - "exec tail -f /dev/null"

2. Log into the Pod

  kubectl exec -it zookeeper-client -- /bin/bash

3. Use zookeeper-shell to connect in the zookeeper-client Pod:

  zookeeper-shell my-kafka-cp-zookeeper:2181

4. Explore with zookeeper commands, for example:

  # Gives the list of active brokers
  ls /brokers/ids

  # Gives the list of topics
  ls /brokers/topics

  # Gives more detailed information of the broker id '0'
  get /brokers/ids/0## ------------------------------------------------------
## Kafka
## ------------------------------------------------------
To connect from a client pod:

1. Deploy a kafka client pod with configuration:

    apiVersion: v1
    kind: Pod
    metadata:
      name: kafka-client
      namespace: test
    spec:
      containers:
      - name: kafka-client
        image: confluentinc/cp-kafka:5.5.0
        command:
          - sh
          - -c
          - "exec tail -f /dev/null"

2. Log into the Pod

  kubectl exec -it kafka-client -- /bin/bash

3. Explore with kafka commands:

  # Create the topic
  kafka-topics --zookeeper my-kafka-cp-zookeeper-headless:2181 --topic my-kafka-topic --create --partitions 1 --replication-factor 1 --if-not-exists

  # Create a message
  MESSAGE="`date -u`"

  # Produce a test message to the topic
  echo "$MESSAGE" | kafka-console-producer --broker-list my-kafka-cp-kafka-headless:9092 --topic my-kafka-topic

  # Consume a test message from the topic
  kafka-console-consumer --bootstrap-server my-kafka-cp-kafka-headless:9092 --topic my-kafka-topic --from-beginning --timeout-ms 2000 --max-messages 1 | grep "$MESSAGE"
```

List the Helm Chart installations (releases)

```console
$ helm list
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
my-kafka        test            1               2020-10-30 01:07:55.530002 +0100 CET    deployed        cp-helm-charts-0.5.0    1.0  
```

List the PersistentVolumeClaims

```console
$ oc get pvc
NAME                                 STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
datadir-0-my-kafka-cp-kafka-0        Bound    pv0018   100Gi      RWO,ROX,RWX                   49s
datadir-my-kafka-cp-zookeeper-0      Bound    pv0021   100Gi      RWO,ROX,RWX                   49s
datalogdir-my-kafka-cp-zookeeper-0   Bound    pv0022   100Gi      RWO,ROX,RWX                   49s
```

List the PersistentVolumes

```console
$ oc get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                        STORAGECLASS   REASON   AGE
pvc-1cc5930f-5132-4027-be0f-b10df7d3d511   107374182400m   RWO            Delete           Bound    default/datalogdir-my-kafka-cp-zookeeper-0   nfs-dynamic             4m20s
pvc-1d873b6c-43bc-4271-9f4e-ed24681fa9c5   107374182400m   RWO            Delete           Bound    default/datadir-0-my-kafka-cp-kafka-0        nfs-dynamic             4m21s
pvc-29a168c3-9d90-484f-96b8-a18873397e3f   107374182400m   RWO            Delete           Bound    default/datalogdir-my-kafka-cp-zookeeper-1   nfs-dynamic             4m12s
pvc-3ee52593-c45b-4715-8975-8861a4677b6f   107374182400m   RWO            Delete           Bound    default/datadir-my-kafka-cp-zookeeper-1      nfs-dynamic             4m12s
pvc-a2b7796b-b5fe-432c-ab7e-1a6d1872307f   107374182400m   RWO            Delete           Bound    default/datadir-my-kafka-cp-zookeeper-0      nfs-dynamic             4m20s
pvc-a9e7fa48-15ac-48c2-9c0e-6a3d8fd316f6   107374182400m   RWO            Delete           Bound    default/datalogdir-my-kafka-cp-zookeeper-2   nfs-dynamic             4m8s
pvc-b4838436-d61f-4ff7-a029-0dd8e094688f   107374182400m   RWO            Delete           Bound    default/datadir-my-kafka-cp-zookeeper-2      nfs-dynamic             4m8s
pvc-e1584bbf-9ca3-4e08-a924-fa7dd81b6512   107374182400m   RWO            Delete           Bound    default/datadir-0-my-kafka-cp-kafka-1        nfs-dynamic             4m18s
```

```console
$ oc get po 
NAME                      READY   STATUS    RESTARTS   AGE
my-kafka-cp-kafka-0       2/2     Running   3          7m49s
my-kafka-cp-kafka-1       2/2     Running   3          4m16s
my-kafka-cp-kafka-2       2/2     Running   3          4m6s
my-kafka-cp-zookeeper-0   2/2     Running   0          7m49s
my-kafka-cp-zookeeper-1   2/2     Running   0          4m16s
my-kafka-cp-zookeeper-2   2/2     Running   0          4m6s
```

## Cleanup

Remove everything:

```console
$ helm uninstall my-kafka
release "my-kafka" deleted
```

```console
$ oc delete pvc --all
persistentvolumeclaim "datadir-0-my-kafka-cp-kafka-0" deleted
persistentvolumeclaim "datadir-0-my-kafka-cp-kafka-1" deleted
persistentvolumeclaim "datadir-my-kafka-cp-zookeeper-0" deleted
persistentvolumeclaim "datadir-my-kafka-cp-zookeeper-1" deleted
persistentvolumeclaim "datadir-my-kafka-cp-zookeeper-2" deleted
persistentvolumeclaim "datalogdir-my-kafka-cp-zookeeper-0" deleted
persistentvolumeclaim "datalogdir-my-kafka-cp-zookeeper-1" deleted
persistentvolumeclaim "datalogdir-my-kafka-cp-zookeeper-2" deleted
```


```console
$ kubectl delete -f ../12-StorageClass/.
service "nfs-provisioner" deleted
serviceaccount "nfs-provisioner" deleted
deployment.apps "nfs-provisioner" deleted
storageclass.storage.k8s.io "nfs-dynamic" deleted
persistentvolumeclaim "nfs" deleted
clusterrole.rbac.authorization.k8s.io "nfs-provisioner-runner" deleted
clusterrolebinding.rbac.authorization.k8s.io "run-nfs-provisioner" deleted
role.rbac.authorization.k8s.io "leader-locking-nfs-provisioner" deleted
rolebinding.rbac.authorization.k8s.io "leader-locking-nfs-provisioner" deleted
```


