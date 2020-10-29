# Job

A job in Kubernetes/OpenShift is a supervisor for pods carrying out batch processes, that is, a process that runs for a certain time to completion, for example a calculation or a backup operation.

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

## Job

Let’s create a job called countdown that supervises a pod counting from 9 down to 1:

```console
$ oc apply -f job.yaml
job.batch/countdown created
```

You can see the job and the pod  like so:

```console
$ oc get jobs
NAME        COMPLETIONS   DURATION   AGE
countdown   1/1           33s        96s
```


```console
$ oc get pods
NAME              READY   STATUS      RESTARTS   AGE
countdown-lqlcr   0/1     Completed   0          107s
```

To learn more about the status of the job, do:

```console
$ oc describe jobs/countdown
Name:           countdown
Namespace:      test
Selector:       controller-uid=fbdd3b03-59e7-4560-a833-84f69179e138
Labels:         controller-uid=fbdd3b03-59e7-4560-a833-84f69179e138
                job-name=countdown
Annotations:    Parallelism:  1
Completions:    1
Start Time:     Thu, 29 Oct 2020 19:37:21 +0100
Completed At:   Thu, 29 Oct 2020 19:37:54 +0100
Duration:       33s
Pods Statuses:  0 Running / 1 Succeeded / 0 Failed
Pod Template:
  Labels:  controller-uid=fbdd3b03-59e7-4560-a833-84f69179e138
           job-name=countdown
  Containers:
   counter:
    Image:      centos:7
    Port:       <none>
    Host Port:  <none>
    Command:
      bin/bash
      -c
      for i in 9 8 7 6 5 4 3 2 1 ; do echo $i ; done
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age   From            Message
  ----    ------            ----  ----            -------
  Normal  SuccessfulCreate  116s  job-controller  Created pod: countdown-lqlcr
  Normal  Completed         83s   job-controller  Job completed
```

And to see the output of the job via the pod it supervised, execute:

```console
$ oc logs countdown-lqlcr
9
8
7
6
5
4
3
2
1
```

To clean up, use the delete verb on the job object which will remove all the supervised pods:

```console
$ oc delete jobs/countdown
job.batch "countdown" deleted
```

## CronJob

Let's try to schedule a CronJob. CronJobs are useful to start a  computation or activity on pre-defined interval.

To try a CronJob resource apply the **cron-job.yaml** config.

```console
$ oc apply -f cron-job.yaml
cronjob.batch/hello created
```

To inspect the CronJob schedule:

```console
$ oc get cronjob hello
NAME    SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
hello   */1 * * * *   False     0        <none>          15s
```

As you can see from the results of the command, the cron job has not scheduled or run any jobs yet. Watch for the job to be created in around one minute:

```console
$ oc get jobs --watch
NAME               COMPLETIONS   DURATION   AGE
hello-1603996920   0/1                      1s
hello-1603996920   0/1           0s         1s
```

To delete the CronJob:

```console
$ oc delete -f cron-job.yaml
cronjob.batch "hello" deleted
```
