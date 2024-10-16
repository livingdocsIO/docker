# Docker

This repo is set up to use automated builds on docker hub.

### Multi arch builds
With Docker:
```
buildcontainer () { docker buildx build --no-cache --platform linux/amd64,linux/arm64  "$@" }
pushcontainer () { for var in "$@"; do docker push "$var"; done }
```

With Lima
```
lima sudo systemctl start containerd
lima sudo nerdctl run --privileged --rm tonistiigi/binfmt:qemu-v7.0.0-28@sha256:66e11bea77a5ea9d6f0fe79b57cd2b189b5d15b93a2bdb925be22949232e4e55 --install all

buildcontainer () { nerdctl build --platform=amd64,arm64 "$@" }
pushcontainer () { for var in "$@"; do nerdctl push --all-platforms "$var"; done }
```

### livingdocs/node

On Docker Hub: https://hub.docker.com/r/livingdocs/node

```sh
buildcontainer -t livingdocs/node:22.0 -t livingdocs/node:22 -f node-22.Dockerfile .
buildcontainer -t livingdocs/node:20.4 -t livingdocs/node:20 -f node-20.Dockerfile .
buildcontainer -t livingdocs/node:18.7 -t livingdocs/node:18 -f node-18.Dockerfile .
pushcontainer livingdocs/node:22.0 livingdocs/node:22
pushcontainer livingdocs/node:20.4 livingdocs/node:20
pushcontainer livingdocs/node:18.7 livingdocs/node:18
```

### livingdocs/server-base

On Docker Hub: https://hub.docker.com/r/livingdocs/server-base

```sh
buildcontainer  -t livingdocs/server-base:22.1 -t livingdocs/server-base:22 -f ./livingdocs-server-base/22.Dockerfile ./livingdocs-server-base
buildcontainer  -t livingdocs/server-base:20.6 -t livingdocs/server-base:20 -f ./livingdocs-server-base/20.Dockerfile ./livingdocs-server-base
buildcontainer  -t livingdocs/server-base:18.8 -t livingdocs/server-base:18 -f ./livingdocs-server-base/18.Dockerfile ./livingdocs-server-base
pushcontainer livingdocs/server-base:22.1 livingdocs/server-base:22
pushcontainer livingdocs/server-base:20.6 livingdocs/server-base:20
pushcontainer livingdocs/server-base:18.8 livingdocs/server-base:18
```

### livingdocs/editor-base

On Docker Hub: https://hub.docker.com/r/livingdocs/editor-base

```sh
buildcontainer  -t livingdocs/editor-base:22.1 -t livingdocs/editor-base:22 -f ./livingdocs-editor-base/22.Dockerfile ./livingdocs-editor-base
buildcontainer  -t livingdocs/editor-base:20.6 -t livingdocs/editor-base:20 -f ./livingdocs-editor-base/20.Dockerfile ./livingdocs-editor-base
buildcontainer  -t livingdocs/editor-base:18.10 -t livingdocs/editor-base:18 -f ./livingdocs-editor-base/18.Dockerfile ./livingdocs-editor-base
pushcontainer livingdocs/editor-base:22.1 livingdocs/editor-base:22
pushcontainer livingdocs/editor-base:20.6 livingdocs/editor-base:20
pushcontainer livingdocs/editor-base:18.10 livingdocs/editor-base:18
```

### livingdocs/docker-node

The official docker image with node, git and curl

On Docker Hub: https://hub.docker.com/r/livingdocs/docker-node

```sh
buildcontainer -t livingdocs/docker-node:22-16 -f ./docker-node/Dockerfile ./docker-node
pushcontainer livingdocs/docker-node:22-16
```

### livingdocs/postgres-exporter

```sh
buildcontainer -t livingdocs/postgres-exporter -f ./postgres-exporter/Dockerfile ./postgres-exporter
pushcontainer livingdocs/postgres-exporter
```

### livingdocs/odyssey

On Docker Hub: https://hub.docker.com/r/livingdocs/odyssey

Build:
```sh
buildcontainer -t livingdocs/odyssey:1.4rc -f odyssey/Dockerfile ./odyssey
pushcontainer livingdocs/odyssey:1.4rc
```

### livingdocs/pgbouncer

On Docker Hub: https://hub.docker.com/r/livingdocs/pgbouncer

Build:
```sh
buildcontainer -t livingdocs/pgbouncer -f ./pgbouncer/Dockerfile ./pgbouncer
pushcontainer livingdocs/pgbouncer
```

### livingdocs/certbot-route53-postgres

On Docker Hub: https://hub.docker.com/r/livingdocs/certbot-route53-postgres

Build:
```sh
buildcontainer -t livingdocs/certbot-route53-postgres -f certbot-route53-postgres.Dockerfile .
pushcontainer livingdocs/certbot-route53-postgres
```

### livingdocs/letsencrypt

On Docker Hub: https://hub.docker.com/r/livingdocs/letsencrypt

A docker image that sets up a daily cronjob and tries to generate certificates if they need renewal.
Certificates are pushed to an s3 bucket, so they can be fetched from other scripts.

Build:
```sh
buildcontainer -t livingdocs/letsencrypt:1.1 -f ./letsencrypt/Dockerfile ./letsencrypt
pushcontainer livingdocs/letsencrypt:1.1
```


### livingdocs/envoy

On Docker Hub: https://hub.docker.com/r/livingdocs/envoy

The envoy docker image with curl, nano and jq, envsubst and [oidc filter](https://github.com/dgn/oidc-filter).

Build:
```sh
buildcontainer -t livingdocs/envoy:v1.31.0 -f ./envoy/Dockerfile ./envoy
pushcontainer livingdocs/envoy:v1.31.0
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
regctl image cp docker.elastic.co/elasticsearch/elasticsearch:6.31 livingdocs/elasticsearch:6.8.21
regctl image cp docker.elastic.co/elasticsearch/elasticsearch:7.17.6 livingdocs/elasticsearch:7.17.6
regctl image cp docker.elastic.co/elasticsearch/elasticsearch:7.17.9 livingdocs/elasticsearch:7.17.9
regctl image cp docker.elastic.co/elasticsearch/elasticsearch:8.4.3 livingdocs/elasticsearch:8.4.3
regctl image cp docker.elastic.co/elasticsearch/elasticsearch:8.7.0 livingdocs/elasticsearch:8.7.0
regctl image cp docker.elastic.co/elasticsearch/elasticsearch:8.12.0 livingdocs/elasticsearch:8.12.0
regctl image cp docker.elastic.co/elasticsearch/elasticsearch:8.13.2 livingdocs/elasticsearch:8.13.2
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
pushcontainer livingdocs/file-change-hook:1.0
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
