# BuildConfig


A build in OpenShift Container Platform is the process of transforming input parameters into a resulting object. Most often, builds are used to transform source code into a runnable container image.

A build configuration, or **BuildConfig**, is characterized by a build strategy and one or more sources. The strategy determines the aforementioned process, while the sources provide its input.

The build strategies are:

- Source-to-Image (S2I) (description, options)
- Pipeline (description, options)
- Docker (description, options)
- Custom (description, options)

And there are six types of sources that can be given as build input:

- Git
- Dockerfile
- Binary
- Image
- Input secrets
- External artifacts

It is up to each build strategy to consider or ignore a certain type of source, as well as to determine how it is to be used. Binary and Git are mutually exclusive source types. Dockerfile and Image can be used by themselves, with each other, or together with either Git or Binary. The Binary source type is unique from the other options in how it is specified to the system.

As output, a BuildConfig can produce:

- ImageStreamTag (a new tag in an ImageStream object)
- DockerImage (push the resulting image to a registry)

A build configuration describes a single build definition and a set of triggers for when a new build should be created. Build configurations are defined by a **BuildConfig** resources.


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

## Simple BuildConfig 


Create the **source** ImageStream to start from.

```console
$ oc import-image ruby:2.4 --from=docker.io/ruby:2.4 --confirm 
imagestream.image.openshift.io/ruby imported

Name:                   ruby
Namespace:              test
Created:                Less than a second ago
Labels:                 <none>
Annotations:            openshift.io/image.dockerRepositoryCheck=2020-10-28T10:40:46Z
Image Repository:       image-registry.openshift-image-registry.svc:5000/test/ruby
Image Lookup:           local=false
Unique Images:          1
Tags:                   1

2.4
  tagged from docker.io/ruby:2.4

  * docker.io/ruby@sha256:87061bde7add4527f77dbc1c06d348f507a4a1bf66b1a2359ebf7918d3f9790f
      Less than a second ago

Image Name:     ruby:2.4
Docker Image:   docker.io/ruby@sha256:87061bde7add4527f77dbc1c06d348f507a4a1bf66b1a2359ebf7918d3f9790f
Name:           sha256:87061bde7add4527f77dbc1c06d348f507a4a1bf66b1a2359ebf7918d3f9790f
Created:        Less than a second ago
Annotations:    image.openshift.io/dockerLayersOrder=ascending
Image Size:     334.2MB in 8 layers
Layers:         50.38MB sha256:f15005b0235fa8bd31cc6988c4f2758016fe412d696e81aecf73e52be079f19e
                7.812MB sha256:41ebfd3d2fd0de99b1c63aa36a507bf5555481d06e571d84ed84440d30671494
                9.996MB sha256:b998346ba308e3362a85c7bf7faed28d0277c68203696134192fe812f809abb2
                51.79MB sha256:f01ec562c947a8ca1b168415da6a4a8f8920808f9b5d6f420ef8fa9af249b1f1
                192.2MB sha256:2447a2c119076510a07d71cfcec029fceac2e59eea21fc7b39cf0eb234d3798e
                200B    sha256:1915e6344d7f76a07a4e6216b33683b8d6f6b544276f079ef0f62b628b3db47a
                22.04MB sha256:e867cf779be3065622441d4a7c6791e5de9a514a77e5d11d390d46968144aff8
                142B    sha256:62af18474b7a0039651c30ac62dc47d3e911726242981e0ddf31da82274044fe
Image Created:  7 months ago
Author:         <none>
Arch:           amd64
Command:        irb
Working Dir:    <none>
User:           <none>
Exposes Ports:  <none>
Docker Labels:  <none>
Environment:    PATH=/usr/local/bundle/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
                RUBY_MAJOR=2.4
                RUBY_VERSION=2.4.10
                RUBY_DOWNLOAD_SHA256=d5668ed11544db034f70aec37d11e157538d639ed0d0a968e2f587191fc530df
                RUBYGEMS_VERSION=3.0.3
                GEM_HOME=/usr/local/bundle
                BUNDLE_SILENCE_ROOT_WARNING=1
                BUNDLE_APP_CONFIG=/usr/local/bundle
```

Create the **target** ImageStream to use as an output in the BuildConfig

```console
$ oc create imagestream ruby-example
imagestream.image.openshift.io/ruby-example created
```

Create the BuildConfig object

```console
$ oc apply -f simple-bc.yaml  
buildconfig.build.openshift.io/simple-bc created
```

```console
$ oc logs build/simple-bc-1 
Cloning "https://github.com/openshift/ruby-ex.git" ...
        Commit: 01effef3a23935c1a83110d4b074b0738d677c44 (Merge pull request #35 from pvalena/bundler)
        Author: Honza Horak <hhorak@redhat.com>
        Date:   Fri Aug 21 13:44:47 2020 +0200
Caching blobs under "/var/cache/blobs".
Getting image source signatures
Copying blob sha256:cf5693de4d3cdd6f352978b87c8f89ead294eff44938598f57a91cf7a02417d2
Copying blob sha256:63abcb3c00123e524cf21f49a099025395236c9c7e525d9ccaa0d8b42060a104
Copying blob sha256:fd542ee251592bb3ed566aa42ccf98987a5607b64823720d19d68ae382e48bb0
Copying blob sha256:23302e52b49d49a0a25da8ea870bc1973e7d51c9b306f3539cd397318bd8b0a5
Copying blob sha256:e3d19bbdc506b3ad0548383b88288658b7b65978afbe6b2cbc673e893568b172
Copying config sha256:be21a2facf1a3a8f170b8f6804d0239fd46fb2f7be998715365ad75b519d79be
Writing manifest to image destination
Storing signatures
Generating dockerfile with builder image image-registry.openshift-image-registry.svc:5000/openshift/ruby@sha256:35e6ada1215bb168d6d9aff01001438a3c35c4fcb64680be3b7f23a5f2257863
STEP 1: FROM image-registry.openshift-image-registry.svc:5000/openshift/ruby@sha256:35e6ada1215bb168d6d9aff01001438a3c35c4fcb64680be3b7f23a5f2257863
STEP 2: LABEL "io.openshift.build.commit.id"="01effef3a23935c1a83110d4b074b0738d677c44"       "io.openshift.build.commit.ref"="master"       "io.openshift.build.commit.message"="Merge pull request #35 from pvalena/bundler"       "io.openshift.build.source-location"="https://github.com/openshift/ruby-ex.git"       "io.openshift.build.image"="image-registry.openshift-image-registry.svc:5000/openshift/ruby@sha256:35e6ada1215bb168d6d9aff01001438a3c35c4fcb64680be3b7f23a5f2257863"       "io.openshift.build.commit.author"="Honza Horak <hhorak@redhat.com>"       "io.openshift.build.commit.date"="Fri Aug 21 13:44:47 2020 +0200"
STEP 3: ENV OPENSHIFT_BUILD_NAME="simple-bc-1"     OPENSHIFT_BUILD_NAMESPACE="test"     OPENSHIFT_BUILD_SOURCE="https://github.com/openshift/ruby-ex.git"     OPENSHIFT_BUILD_REFERENCE="master"     OPENSHIFT_BUILD_COMMIT="01effef3a23935c1a83110d4b074b0738d677c44"
STEP 4: USER root
STEP 5: COPY upload/src /tmp/src
STEP 6: RUN chown -R 1001:0 /tmp/src
STEP 7: USER 1001
STEP 8: RUN /usr/libexec/s2i/assemble
---> Installing application source ...
---> Building your Ruby application from source ...
---> Running 'bundle install --retry 2 --deployment --without development:test' ...
Fetching gem metadata from https://rubygems.org/..
Fetching version metadata from https://rubygems.org/.
Installing nio4r 2.5.2 with native extensions
Installing rack 2.2.3
Using bundler 1.13.7
Installing puma 4.3.5 with native extensions
Bundle complete! 2 Gemfile dependencies, 4 gems now installed.
Gems in the groups development and test were not installed.
Bundled gems are installed into ./bundle.
---> Cleaning up unused ruby gems ...
Running `bundle clean   --verbose` with bundler 1.13.7
Found no changes, using resolution from the lockfile
STEP 9: CMD /usr/libexec/s2i/run
STEP 10: COMMIT temp.builder.openshift.io/test/simple-bc-1:d9cda747
Getting image source signatures
Copying blob sha256:35b7a5c4e1b4a84fb05d9c6658572c2b7a9925a270e8f7860c0ae30671c0a57c
Copying blob sha256:eddcd8d2986daee57d8cd75add7ff3c998e668857847e0f2b3c3d3b7e02a3ab6
Copying blob sha256:f0f97bb39344256e639831d65c0c9db84aca2e9b0f1507f267b7cc128068fff0
Copying blob sha256:5a9c62a939b5a7eb752536378f00381f42c8cb293a026b29fa4a9384e56da6af
Copying blob sha256:1a32ec1f79fd27c51b9c9a733b814ec42c57934bba2970fe5cd7dd40c30e8f17
Copying blob sha256:7d78550a407e643ceee681e8009bffd70b4bed2fa47db6a1678c74debf9b9905
Copying config sha256:7d040ddb4ce93c1cde3d4f2b2f9e40d160773169469d88122ab1e4cd6a5236e5
Writing manifest to image destination
Storing signatures
--> 7d040ddb4ce
7d040ddb4ce93c1cde3d4f2b2f9e40d160773169469d88122ab1e4cd6a5236e5

Pushing image image-registry.openshift-image-registry.svc:5000/test/ruby-example:latest ...
Getting image source signatures
Copying blob sha256:7d78550a407e643ceee681e8009bffd70b4bed2fa47db6a1678c74debf9b9905
Copying blob sha256:23302e52b49d49a0a25da8ea870bc1973e7d51c9b306f3539cd397318bd8b0a5
Copying blob sha256:e3d19bbdc506b3ad0548383b88288658b7b65978afbe6b2cbc673e893568b172
Copying blob sha256:fd542ee251592bb3ed566aa42ccf98987a5607b64823720d19d68ae382e48bb0
Copying blob sha256:cf5693de4d3cdd6f352978b87c8f89ead294eff44938598f57a91cf7a02417d2
Copying blob sha256:63abcb3c00123e524cf21f49a099025395236c9c7e525d9ccaa0d8b42060a104
Copying config sha256:7d040ddb4ce93c1cde3d4f2b2f9e40d160773169469d88122ab1e4cd6a5236e5
Writing manifest to image destination
Storing signatures
Successfully pushed image-registry.openshift-image-registry.svc:5000/test/ruby-example@sha256:4c1bf55a3fee613fec88ddcafb414004631a6fdfe4d19779bf4a2681ba4ba05d
Push successful
```

If, for any case, you need to manually start a new build, just type:

```console
$ oc start-build simple-bc 
build.build.openshift.io/ruby-sample-build-2 started
```

Inspect the target ImageStream

```console
$ oc get is ruby-example
Name:                   ruby-example
Namespace:              test
Created:                27 minutes ago
Labels:                 <none>
Annotations:            <none>
Image Repository:       default-route-openshift-image-registry.apps-crc.testing/test/ruby-example
Image Lookup:           local=false
Unique Images:          2
Tags:                   1

latest
  no spec tag

  * image-registry.openshift-image-registry.svc:5000/test/ruby-example@sha256:06a7503984409c788eb19db164e472b65b657b7b0da0c6a2959e47a2060293ac
      24 minutes ago
    image-registry.openshift-image-registry.svc:5000/test/ruby-example@sha256:4c1bf55a3fee613fec88ddcafb414004631a6fdfe4d19779bf4a2681ba4ba05d
      25 minutes ago
```


Run the application

```console
$ oc new-app test/ruby-example:latest
--> Found image 9511900 (40 minutes old) in image stream "test/ruby-example" under tag "latest" for "test/ruby-example:latest"

    Ruby 2.4 
    -------- 
    Ruby 2.4 available as container is a base platform for building and running various Ruby 2.4 applications and frameworks. Ruby is the interpreted scripting language for quick and easy object-oriented programming. It has many features to process text files and to do system management tasks (as in Perl). It is simple, straight-forward, and extensible.

    Tags: builder, ruby, ruby24, rh-ruby24


--> Creating resources ...
    deployment.apps "ruby-example" created
    service "ruby-example" created
--> Success
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose svc/ruby-example' 
    Run 'oc status' to view your app.
```

Check the resulting Deployment

```console
$ oc get deploy 
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
ruby-example   1/1     1            1           65m
```

Check the Pods

```console
$ oc get pods
NAME                           READY   STATUS      RESTARTS   AGE
ruby-example-859bb5d85-zt5p4   1/1     Running     0          65m
simple-bc-1-build              0/1     Completed   0          108m
```

## Cleanup

Delete the BuildConfig

```console
$ oc delete bc simple-bc
buildconfig.build.openshift.io "simple-bc" deleted
```

Delete ImageStreams

```console
$ oc delete is ruby-example ruby
imagestream.image.openshift.io "ruby-example" deleted
imagestream.image.openshift.io "ruby" deleted
```

Delete the Deployment

```console
$ oc delete deploy ruby-example
```