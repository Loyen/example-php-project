# Kubernetes

In this document I will explain how I created the Kubernetes + Skaffold configuration that can be found in this repository.
The configuration is set using overlays, so we have a profile to use for each environment we would like to deploy towards, but also a base for all of them to build upon.

The directory structure looks something like this:

```
kustomize/
├── base
└── overlays
    └── local
```

## Prerequisites

In order to create the configuration, you have to have the tools for it.

* [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [Kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)
* [Skaffold](https://skaffold.dev/docs/install/)

You will also need a Kubernetes cluster. I've used [Mikrok8s](https://microk8s.io/) and [Minikube](https://minikube.sigs.k8s.io/docs/start/).

## Creating a base

Let's start off by creating the directories needed to create our configuration and go to the base directory.

```
$ mkdir -p kustomize/base
$ cd kustomize/base
```

Now, we will need to create three files:
* A deployment configuration file that tells Kubernetes what we want to run.
* A service configuration file that makes us able to expose ports to connect to the deployment pod.
* A Kustomization file that includes all resources that should be deployed (deployment+service and what else you might want to add).

We will start off by creating the deployment file. We can for the most part generate this file using `kubectl create`.

```
kubectl create deployment app --image=app-loadbalancer --image=app-backend -o yaml --dry-run=client > deployment.yaml
```

This will create a deployment configuration named `app` containing two containers (`app-loadbalancer` and `app-backend`) that uses images with the same name as the containers. Since we want to output the configuration file in yaml and also not actually create the deployment just yet, we use `-o yaml` and `--dry-run=client` to output the created configuration instead and then redirect it to the file `deployment.yaml`.

As the app-loadbalancer requires environment variables to fill in the nginx configuration template, we will have to add this afterwards. We also want to tell that this container exposes port `80`. Open the file up and amend the `app-loadbalancer` with the following data:
```
       - image: app-loadbalancer
         name: app-loadbalancer
         resources: {}
+        ports:
+        - containerPort: 80
+        env:
+          - name: FASTCGI_PASS
+            value: "127.0.0.1:9000"
```

Now we need to create a service. In a similar fashion we can run:

```
kubectl create service clusterip app -o yaml --tcp=80:80 --dry-run=client > service.yaml
```

This will create a service configuration named `app` which exposes port `80` towards the deployment.

Now to create the kustomize file to bundle these within. First we have to create the file so kustomize has a file to work with, then we can add the resources to it.

```
$ touch kustomization.yaml
$ kustomize edit add resource deployment.yaml
$ kustomize edit add resource service.yaml
```

The base should now be done.

## Creating an overlay

Lets move back out of the base directory and create the directory structure for a local overlay and go that directory.

```
$ cd ..
$ mkdir -p overlays/local
$ cd overlays/local
```

Since we currently do not have anything special to add to the local overlay, just created a `kustomization.yaml` configuration file and include the base directory into it. This will make it include whatever is done within `kustomization.yaml` file in the base directory and we can add to it.

```
$ touch kustomization.yaml
$ kustomize edit add resource ../../base
```

## Creating the Skaffold configuration

Now that we have our base configuration setup, including an overlay, setting up skaffold is pretty easy. First we need to move back to the root of the project, and then we can initialize the skaffold configuration.

```
$ cd ../../../
$ skaffold init
```

You will then be prompted to answer two questions regarding what dockerfiles to use when building the deployments containers.
```
? Choose the builder to build image app-backend  [Use arrows to move, enter to select, type to filter]
> Docker (Dockerfile-backend)
  Docker (Dockerfile-loadbalancer)
  None (image not built from these sources)
```
Once both images have been selected, it will output the finished configuration and prompt if you want it to create the configuration file. Once you respond with `y` everything should be setup.

You should now be ready to run the project using `skaffold run -p local` or if you want it to continously deploy whenever you do changes you can run it using `skaffold dev -p local`.