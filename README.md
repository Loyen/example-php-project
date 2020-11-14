# Example PHP Project

This is an example project made to show how to setup a PHP project to be run through either Docker Compose or Kubernetes. It uses Nginx as a loadbalancer which forwards PHP requests to a PHP FPM container.

Both are setup in pretty similar ways, but there are differences.

When we run the project through `docker-compose up`, we start two containers:
* `app` (our PHP-FPM container)
* `loadbalancer` (our nginx container)

These use the official images from Nginx and PHP-FPM which we then mount our configuration and source code into using volumes.

When we run `skaffold run -plocal` to deploy the project to Kubernetes using the local profile (which is setup to use MicroK8s), it builds two docker images:
* `app-frontend`
* `app-loadbalancer`

These will copy our configuration as well as the source code into the the images and then use these images in our deployment. If we use `skaffold dev -plocal` these images will be rebuilt everytime our configuration or source code changes.