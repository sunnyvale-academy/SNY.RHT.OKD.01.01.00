# Template 

A template describes a set of objects that can be parameterized and processed to produce a list of objects for creation by OpenShift Container Platform. A template can be processed to create anything you have permission to create within a project, for example services, build configurations, and deployment configurations. A template may also define a set of labels to apply to every object defined in the template.

You can create a list of objects from a template using the CLI or the Web UI.

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


## Template creation 

```console
$ oc apply -f node-posgres.yaml
template.template.openshift.io/my-nodejs-postgresql-example created
```


```console
$ oc get templates 
NAME                        DESCRIPTION                                                                        PARAMETERS     OBJECTS
my-nodejs-postgresql-example   An example Node.js application with a PostgreSQL database. For more informati...   18 (4 blank)   8
```


## New application from Template using Web UI

Open the Web UI

```console
$ crc console
Opening the OpenShift Web Console in the default browser...
```

The Web UI opens, create a new application "From Catalog"

Using the textfield, search for the newly created **My Node.js + PostgreSQL (Ephemeral)** Template and click on it.

Click on "Instantiate Template"

Fill-up all the Template parameters (you also leave them as the default values suggest) and click on "Create"

As soon as you click on "Create", the topology gets populated with DeploymentConfig specified in the Template as well as other kind of resources (BuildConfig, Service, Route, etc).

Wait a few minutes for the build process to complete, then test the application.

## New application from Template using the CLI (alternatively to the Web UI)

As an alternative, the previous operation can also be done using CLI as shown below:

```console
$ oc new-app my-nodejs-postgresql-example
--> Deploying template "test/my-nodejs-postgresql-example" to project test

     My Node.js + PostgreSQL (Ephemeral)
     ---------
     An example Node.js application with a PostgreSQL database. For more information about using this template, including OpenShift considerations, see https://github.com/nodeshift-starters/nodejs-rest-http-crud/blob/master/README.md.
     
     WARNING: Any data stored will be lost upon pod destruction. Only use this template for testing.

     The following service(s) have been created in your project: nodejs-postgresql-example, postgresql.
     
     For more information about using this template, including OpenShift considerations, see https://github.com/nodeshift-starters/nodejs-rest-http-crud/blob/master/README.md.

     * With parameters:
        * Name=nodejs-postgresql-example
        * Namespace=openshift
        * Version of NodeJS Image=16-ubi8
        * Version of PostgreSQL Image=12-el8
        * Memory Limit=256Mi
        * Memory Limit (PostgreSQL)=256Mi
        * Git Repository URL=https://github.com/nodeshift-starters/nodejs-rest-http-crud.git
        * Git Reference=
        * Context Directory=
        * Application Hostname=
        * GitHub Webhook Secret=XWOQ2uF4EoPeK3mkjLghEWclLWfToi3fIHGRIY64 # generated
        * Generic Webhook Secret=iPF4dBk7CgSaN0lRb7KLD7mXPYeNkptYjPSBLs6Q # generated
        * Database Service Name=postgresql
        * PostgreSQL Username=userAR8 # generated
        * PostgreSQL Password=oAcPohll5pWHVVFf # generated
        * Database Name=my_data
        * Database Administrator Password=o3xCQvJ0DX0IJX3J # generated
        * Custom NPM Mirror URL=

--> Creating resources ...
    secret "nodejs-postgresql-example" created
    service "nodejs-postgresql-example" created
    route.route.openshift.io "nodejs-postgresql-example" created
    imagestream.image.openshift.io "nodejs-postgresql-example" created
    buildconfig.build.openshift.io "nodejs-postgresql-example" created
Warning: apps.openshift.io/v1 DeploymentConfig is deprecated in v4.14+, unavailable in v4.10000+
    deploymentconfig.apps.openshift.io "nodejs-postgresql-example" created
    service "postgresql" created
    deploymentconfig.apps.openshift.io "postgresql" created
--> Success
    Access your application via route 'nodejs-postgresql-example-test.apps-crc.testing' 
    Build scheduled, use 'oc logs -f buildconfig/nodejs-postgresql-example' to track its progress.
    Run 'oc status' to view your app.
```

## Access to the application

Just point your browser to the Route URL http://nodejs-postgresql-example-test.apps-crc.testing, your application should be displayed


If not already available, wait a few minutes for the Pods to be running.


## See also

More templates can be found at https://github.com/openshift/origin/tree/master/examples/quickstarts

## Cleanup

```console
$ oc process my-nodejs-postgresql-example | oc delete -f -
secret "nodejs-postgresql-example" deleted
service "nodejs-postgresql-example" deleted
route.route.openshift.io "nodejs-postgresql-example" deleted
imagestream.image.openshift.io "nodejs-postgresql-example" deleted
buildconfig.build.openshift.io "nodejs-postgresql-example" deleted
deploymentconfig.apps.openshift.io "nodejs-postgresql-example" deleted
service "postgresql" deleted
deploymentconfig.apps.openshift.io "postgresql" deleted
```