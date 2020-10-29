# Route

An OpenShift **Route** exposes a service at a host name, such as www.example.com, so that external clients can reach it by name (similar to Ingress, but OpenShift Routes have been invented a long time before Kubernetes Ingress resource came along).

When a Route object is created on OpenShift, it gets picked up by the built-in HAProxy load balancer in order to expose the requested service and make it externally available with the given configuration.

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

## Deploy the applications to be accessed externally

First we create the backend **Deployments** and **Services** used later in Route examples.

```console
$ oc apply -f nginx-deployment.yaml 
deployment.apps/nginx-deployment created
```


```console
$ oc apply -f nginx-svc.yaml        
service/nginx-service created  
```

```console
$ oc apply -f whoami-deployment.yaml 
deployment.apps/whoami-deployment created
```


```console
$ oc apply -f whoami-svc.yaml        
service/whoami-service created  
```

## Create an HTTP Route

Create the Route

```console
$ oc expose svc/nginx-service --hostname=api.crc.testing
route.route.openshift.io/nginx-service exposed
```

See if the Route has been created

```console
$ oc get routes       
NAME            HOST/PORT         PATH   SERVICES        PORT   TERMINATION   WILDCARD
nginx-service   api.crc.testing          nginx-service   http                 None
```

Test the Route using the domain name specified in the `oc route` `--hostname` parameter (api.crc.testing).

```console
$ curl api.crc.testing
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

Everything worked, we reached the NGINX Pod thanks to the Route we created.

A Route can also be described using YAML, please refer to the same route expressed in YAML at [nginx-unsecured-route.yaml](nginx-unsecured-route.yaml)

## Create an HTTPS/SSL Route

Generate a self signed certificate (you need to have openssl installed)

```console
$ openssl req -nodes -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -subj '/CN=api.crc.testing' 
Generating a 4096 bit RSA private key
.........++
..........................++
unable to write 'random state'
writing new private key to 'key.pem'
-----
```

Create the Route

```console
$ oc create route edge --service=nginx-service \
    --cert=cert.pem \
    --key=key.pem \
    --ca-cert=cert.pem \
    --hostname=api.crc.testing
route.route.openshift.io/nginx-service created
```

Test the HTTPS Route

```console
$ curl -vvv -k https://api.crc.testing 
* Rebuilt URL to: https://api.crc.testing/
*   Trying 192.168.64.13...
* Connected to api.crc.testing (192.168.64.13) port 443 (#0)
* ALPN, offering http/1.1
* Cipher selection: ALL:!EXPORT:!EXPORT40:!EXPORT56:!aNULL:!LOW:!RC4:@STRENGTH
* successfully set certificate verify locations:
*   CAfile: /Applications/XAMPP/xamppfiles/share/curl/curl-ca-bundle.crt
  CApath: none
* TLSv1.2 (OUT), TLS header, Certificate Status (22):
* TLSv1.2 (OUT), TLS handshake, Client hello (1):
* TLSv1.2 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):
* TLSv1.2 (IN), TLS handshake, Server finished (14):
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
* TLSv1.2 (OUT), TLS change cipher, Client hello (1):
* TLSv1.2 (OUT), TLS handshake, Finished (20):
* TLSv1.2 (IN), TLS change cipher, Client hello (1):
* TLSv1.2 (IN), TLS handshake, Finished (20):
* SSL connection using TLSv1.2 / ECDHE-RSA-AES128-GCM-SHA256
* ALPN, server did not agree to a protocol
* Server certificate:
*        subject: CN=api.crc.testing
*        start date: Oct 28 23:32:25 2020 GMT
*        expire date: Oct 28 23:32:25 2021 GMT
*        issuer: CN=api.crc.testing
*        SSL certificate verify result: self signed certificate (18), continuing anyway.
> GET / HTTP/1.1
> Host: api.crc.testing
> User-Agent: curl/7.45.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< server: nginx/1.19.3
< date: Wed, 28 Oct 2020 23:37:47 GMT
< content-type: text/html
< content-length: 612
< last-modified: Tue, 29 Sep 2020 14:12:31 GMT
< etag: "5f7340cf-264"
< accept-ranges: bytes
< set-cookie: 9acc81d8ac9f7b003fade42e58fe2d33=e3a177ef3554b91db85ce70dac49ac7e; path=/; HttpOnly; Secure
< cache-control: private
< 
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
* Connection #0 to host api.crc.testing left intact
```

Everything worked, we reached the NGINX Pod thanks to the HTTPS Route we created.

An HTTPS route can also be described using YAML, please refer to the same route expressed in YAML at [nginx-https-route.yaml](nginx-https-route.yaml)

## Path based Route

Path based routes specify a path component that can be compared against a URL such that multiple routes can be served using the same host name, each with a different path.


Create the nginx path-based Route

```console
$ oc apply -f nginx-path-based-route.yaml      
route.route.openshift.io/nginx-path-based-route created
```

Create the whoami path-based Route

```console
$ oc apply -f whoami-path-based-route.yaml      
route.route.openshift.io/whoami-path-based-route created
```

See the Routes just created

```console
$ oc get routes
NAME                      HOST/PORT         PATH          SERVICES         PORT    TERMINATION   WILDCARD
nginx-path-based-route    api.crc.testing   /index.html   nginx-service    <all>                 None
whoami-path-based-route   api.crc.testing   /whoami       whoami-service   <all>                 None
```

Test the nginx path-based Route

```console
$  curl http://api.crc.testing/index.html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

Test the whoami path-based Route

```console
$ curl http://api.crc.testing/whoami 
Hostname: whoami-deployment-65bf559756-ztrvc
IP: 127.0.0.1
IP: ::1
IP: 10.116.0.70
IP: fe80::1438:80ff:fe23:4767
RemoteAddr: 10.116.0.1:56462
GET /whoami HTTP/1.1
Host: api.crc.testing
User-Agent: curl/7.45.0
Accept: */*
Forwarded: for=192.168.64.1;host=api.crc.testing;proto=http
X-Forwarded-For: 192.168.64.1
X-Forwarded-Host: api.crc.testing
X-Forwarded-Port: 80
X-Forwarded-Proto: http
```

## Creanup

Delete Routes

```console
$ oc delete routes --all
route.route.openshift.io "nginx-path-based-route" deleted
route.route.openshift.io "whoami-path-based-route" deleted
```

Delete Services

```console
$ oc delete service --all
service "nginx-service" deleted
service "whoami-service" deleted
```

Delete Deployments

```console
$ oc delete deploy --all
deployment.apps "nginx-deployment" deleted
deployment.apps "whoami-deployment" deleted
```

