# Docker

This repo is set up to use automated builds on docker hub.

### Multi arch builds

For multi arch builds on Docker we use buildx. You have to create a builder before being able to build the containers.
```
docker buildx create --name container --driver=docker-container
```

The following functions are used to build and push images on x86 machines:
```
buildcontainer () { docker buildx build --no-cache --platform linux/amd64,linux/arm64  "$@" }
pushcontainer () { for var in "$@"; do docker push "$var"; done }
```

On Apple Silicon Macs, you have to upload the images to a registry that supports multi-arch images in one step.

```
buildcontainer () { docker buildx build --no-cache --push --platform linux/amd64,linux/arm64  "$@" }
```

With Lima
```
lima sudo systemctl start containerd
lima sudo nerdctl run --privileged --rm tonistiigi/binfmt:qemu-v8.1.5 --install all

buildcontainer () { nerdctl build --platform=amd64,arm64 "$@" }
pushcontainer () { for var in "$@"; do nerdctl push --all-platforms "$var"; done }
```

### livingdocs/node

On Docker Hub: https://hub.docker.com/r/livingdocs/node

```sh
buildcontainer -t livingdocs/node:24.0 -t livingdocs/node:24 -f node-24.Dockerfile .
buildcontainer -t livingdocs/node:22.5 -t livingdocs/node:22 -f node-22.Dockerfile .
buildcontainer -t livingdocs/node:20.9 -t livingdocs/node:20 -f node-20.Dockerfile .
pushcontainer livingdocs/node:24.0 livingdocs/node:24 # skip it when using docker
pushcontainer livingdocs/node:22.5 livingdocs/node:22 # skip it when using docker
pushcontainer livingdocs/node:20.9 livingdocs/node:20 # skip it when using docker
```

### livingdocs/server-base

On Docker Hub: https://hub.docker.com/r/livingdocs/server-base

```sh
buildcontainer  -t livingdocs/server-base:24.0-pc -t livingdocs/server-base:24-pc -f ./livingdocs-server-base/24-pc.Dockerfile ./livingdocs-server-base
buildcontainer  -t livingdocs/server-base:24.0 -t livingdocs/server-base:24 -f ./livingdocs-server-base/24.Dockerfile ./livingdocs-server-base
buildcontainer  -t livingdocs/server-base:22.6 -t livingdocs/server-base:22 -f ./livingdocs-server-base/22.Dockerfile ./livingdocs-server-base
buildcontainer  -t livingdocs/server-base:20.11 -t livingdocs/server-base:20 -f ./livingdocs-server-base/20.Dockerfile ./livingdocs-server-base
pushcontainer livingdocs/server-base:24.0 livingdocs/server-base:24 # skip it when using docker
pushcontainer livingdocs/server-base:22.6 livingdocs/server-base:22 # skip it when using docker
pushcontainer livingdocs/server-base:20.11 livingdocs/server-base:20 # skip it when using docker
```

### livingdocs/editor-base

On Docker Hub: https://hub.docker.com/r/livingdocs/editor-base

```sh
buildcontainer  -t livingdocs/editor-base:24.0 -t livingdocs/editor-base:24 -f ./livingdocs-editor-base/24.Dockerfile ./livingdocs-editor-base
buildcontainer  -t livingdocs/editor-base:22.6 -t livingdocs/editor-base:22 -f ./livingdocs-editor-base/22.Dockerfile ./livingdocs-editor-base
buildcontainer  -t livingdocs/editor-base:20.11 -t livingdocs/editor-base:20 -f ./livingdocs-editor-base/20.Dockerfile ./livingdocs-editor-base
pushcontainer livingdocs/editor-base:24.0 livingdocs/editor-base:24 # skip it when using docker
pushcontainer livingdocs/editor-base:22.6 livingdocs/editor-base:22 # skip it when using docker
pushcontainer livingdocs/editor-base:20.11 livingdocs/editor-base:20 # skip it when using docker
```

### livingdocs/docker-node

The official docker image with node, git and curl

On Docker Hub: https://hub.docker.com/r/livingdocs/docker-node

```sh
buildcontainer -t livingdocs/docker-node:22-16 -f ./docker-node/Dockerfile ./docker-node
pushcontainer livingdocs/docker-node:22-16 # skip it when using docker
```

### livingdocs/postgres-exporter

```sh
buildcontainer -t livingdocs/postgres-exporter -f ./postgres-exporter/Dockerfile ./postgres-exporter
pushcontainer livingdocs/postgres-exporter # skip it when using docker
```

### livingdocs/odyssey

On Docker Hub: https://hub.docker.com/r/livingdocs/odyssey

Build:
```sh
buildcontainer -t livingdocs/odyssey:1.4rc -f odyssey/Dockerfile ./odyssey
pushcontainer livingdocs/odyssey:1.4rc # skip it when using docker
```

### livingdocs/pgbouncer

On Docker Hub: https://hub.docker.com/r/livingdocs/pgbouncer

Build:
```sh
buildcontainer -t livingdocs/pgbouncer -f ./pgbouncer/Dockerfile ./pgbouncer
pushcontainer livingdocs/pgbouncer # skip it when using docker
```

### livingdocs/certbot-route53-postgres

On Docker Hub: https://hub.docker.com/r/livingdocs/certbot-route53-postgres

Build:
```sh
buildcontainer -t livingdocs/certbot-route53-postgres -f certbot-route53-postgres.Dockerfile .
pushcontainer livingdocs/certbot-route53-postgres # skip it when using docker
```

### livingdocs/letsencrypt

On Docker Hub: https://hub.docker.com/r/livingdocs/letsencrypt

A docker image that sets up a daily cronjob and tries to generate certificates if they need renewal.
Certificates are pushed to an s3 bucket, so they can be fetched from other scripts.

Build:
```sh
buildcontainer -t livingdocs/letsencrypt:1.1 -f ./letsencrypt/Dockerfile ./letsencrypt
pushcontainer livingdocs/letsencrypt:1.1 # skip it when using docker
```


### livingdocs/envoy

On Docker Hub: https://hub.docker.com/r/livingdocs/envoy

The envoy docker image with curl, nano and jq, envsubst and [oidc filter](https://github.com/dgn/oidc-filter).

Build:
```sh
buildcontainer -t livingdocs/envoy:v1.31.0 -f ./envoy/Dockerfile ./envoy
pushcontainer livingdocs/envoy:v1.31.0 # skip it when using docker
```


### livingdocs/fetch-certificate

On Docker Hub: https://hub.docker.com/r/livingdocs/fetch-certificate

Works together with livingdocs/letsencrypt to download a certificate into a file.
It's just doing an http request and writing two files. Basically a simple curl command could
do the same thing, but I just wanted to test rust for something.

Use:
```sh
docker run -it --rm \
  -e FETCH_CERTIFICATE_TOKEN="JWT.GF...SD.SJQ" \
  -e FETCH_CERTIFICATE_URL='https://letsencrypt.livingdocs.io' \
  -e FETCH_CERTIFICATE_FILE='/etc/certificates/postgres.livingdocs.io' \
  livingdocs/fetch-certificate
```

### livingdocs/elasticsearch

Build:
```sh
regctl image cp docker.elastic.co/elasticsearch/elasticsearch:7.17.9 livingdocs/elasticsearch:7.17.9
regctl image cp docker.elastic.co/elasticsearch/elasticsearch:8.18.0 livingdocs/elasticsearch:8.18.0
regctl image cp docker.elastic.co/elasticsearch/elasticsearch:9.0.0 livingdocs/elasticsearch:9.0.0
```

Use:
```sh
docker run --name elasticsearch8 -p 9200:9200 -e 'discovery.type=single-node' livingdocs/elasticsearch:8.12.0
```


### livingdocs/kubectl:3

Kubectl as drone plugin used to upgrade an image of a container in a deployment.

Build:
```sh
docker build -t livingdocs/kubectl:3 -f ./kubectl/Dockerfile ./kubectl
```

Use: .drone.yaml
```yaml
steps:
- name: kubernetes
  image: livingdocs/kubectl
  settings:
    namespace: blue-dev
    deployment: swisscom-tv-delivery
    image: "livingdocs/swisscom-tv-delivery:${DRONE_TAG}"
    container: delivery
    config:
      # The whole kubernetes config file content
      from_secret: kube_config
```


### livingdocs/file-change-hook

An alternative to https://github.com/weaveworks/watch

On Docker Hub: https://hub.docker.com/r/livingdocs/file-change-hook

A small service that can be deployed as sidecar that watches files and triggers
a script when they change. This can be used for example to trigger a config reload in a service
upon a ConfigMap change in kubernetes.

The image has some dependencies pre-installed: `bash`, `curl`, `dig`, `jq`

Build:
```sh
buildcontainer -t livingdocs/file-change-hook:1.0 -f ./file-change-hook/Dockerfile ./file-change-hook
pushcontainer livingdocs/file-change-hook:1.0 # skip it when using docker
```

Use:
```sh
Usage: file-change-hook <command> <file-or-directory> [<another-file-or-directory>...]

docker run -v $PWD:/data livingdocs/file-change-hook:1.0 "echo Some file in /data changed" /data
```

## Some other useful setups

- Varnish: https://github.com/livingdocsIO/dockerfile-varnish
- Loki & Grafana for a local setup: https://github.com/livingdocsIO/loki
- Squid, the http proxy: https://github.com/livingdocsIO/squid

### livingdocs/azcopy

Build:
```sh
buildcontainer -t livingdocs/azcopy:1.0 -f ./azcopy/Dockerfile ./azcopy
pushcontainer livingdocs/azcopy:1.0 # skip it when using docker
```

Use:
```sh
docker run --name azcopy livingdocs/azcopy
```
