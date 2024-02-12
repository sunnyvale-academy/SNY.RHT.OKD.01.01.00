# ResourceQuota and ClusterResourceQuota

## ResourceQuota

A **ResourceQuota**, defined by a ResourceQuota object, provides constraints that limit aggregate resource consumption per project/namespace. On OpenShift, it can limit the quantity of objects that can be created in a project by type, as well as the total amount of compute resources and storage that might be consumed by resources in that project.

![Kubernetes](https://img.shields.io/badge/Kubernetes-informational?logo=Kubernetes&color=blue&logoColor=white&style=for-the-badge&logoWidth=30)

![OpenShift](https://img.shields.io/badge/OpenShift-informational?logo=Red%20Hat%20Open%20Shift&color=black&logoColor=red&style=for-the-badge&logoWidth=30)



### References

- https://docs.openshift.com/container-platform/4.14/applications/quotas/quotas-setting-per-project.html

## ClusterResourceQuota

A multi-project quota, defined by **ClusterResourceQuota** object, allows quotas to be shared across multiple projects. 

ClusterResourceQuota is an OpenShift-only feature

![OpenShift](https://img.shields.io/badge/OpenShift-informational?logo=Red%20Hat%20Open%20Shift&color=black&logoColor=red&style=for-the-badge&logoWidth=30)

### References

- https://docs.openshift.com/container-platform/4.14/applications/quotas/quotas-setting-across-multiple-projects.html