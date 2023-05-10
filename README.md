# Docker

This repo is set up to use automated builds on docker hub.

### livingdocs/node

On Docker Hub: https://hub.docker.com/r/livingdocs/node

```sh
docker build -t livingdocs/node:20.0 -t livingdocs/node:20 - < node-20.Dockerfile
docker build -t livingdocs/node:18.3 -t livingdocs/node:18 - < node-18.Dockerfile
docker build -t livingdocs/node:16.3 -t livingdocs/node:16 - < node-16.Dockerfile
docker push livingdocs/node:18
docker push livingdocs/node:18.3
docker push livingdocs/node:16
docker push livingdocs/node:16.3
```

### livingdocs/server-base

On Docker Hub: https://hub.docker.com/r/livingdocs/server-base

```sh
docker build -f ./livingdocs-server-base/20.Dockerfile -t livingdocs/server-base:20.0 -t livingdocs/server-base:20 ./livingdocs-server-base
docker build -f ./livingdocs-server-base/18.Dockerfile -t livingdocs/server-base:18.2 -t livingdocs/server-base:18 ./livingdocs-server-base
docker build -f ./livingdocs-server-base/16.Dockerfile -t livingdocs/server-base:16.4 -t livingdocs/server-base:16 ./livingdocs-server-base
docker push livingdocs/server-base:20
docker push livingdocs/server-base:20.0
docker push livingdocs/server-base:18
docker push livingdocs/server-base:18.2
docker push livingdocs/server-base:16
docker push livingdocs/server-base:16.4
```

### livingdocs/editor-base

On Docker Hub: https://hub.docker.com/r/livingdocs/editor-base

```sh
docker build -t livingdocs/editor-base:20.0 -t livingdocs/editor-base:20 - < ./livingdocs-editor-base/20.Dockerfile
docker build -t livingdocs/editor-base:18.4 -t livingdocs/editor-base:18 - < ./livingdocs-editor-base/18.Dockerfile
docker build -t livingdocs/editor-base:16.4 -t livingdocs/editor-base:16 - < ./livingdocs-editor-base/16.Dockerfile
docker push livingdocs/editor-base:20
docker push livingdocs/editor-base:20.0
docker push livingdocs/editor-base:18
docker push livingdocs/editor-base:18.4
docker push livingdocs/editor-base:16
docker push livingdocs/editor-base:16.4
```

### livingdocs/docker-node

The official docker image with node, git and curl

On Docker Hub: https://hub.docker.com/r/livingdocs/docker-node

```sh
docker build -t livingdocs/docker-node:22-16 -f ./docker-node/Dockerfile ./docker-node
docker push livingdocs/docker-node:22-16
```

### livingdocs/postgres-exporter

```sh
docker build -t livingdocs/postgres-exporter -f ./postgres-exporter/Dockerfile ./postgres-exporter
docker push livingdocs/postgres-exporter
```

### livingdocs/odyssey

On Docker Hub: https://hub.docker.com/r/livingdocs/odyssey

Build:
```sh
docker build -t livingdocs/odyssey:1.3 -f odyssey/Dockerfile ./odyssey
docker push livingdocs/odyssey:1.3
```

### livingdocs/pgbouncer

On Docker Hub: https://hub.docker.com/r/livingdocs/pgbouncer

Build:
```sh
docker build -t livingdocs/pgbouncer -f ./pgbouncer/Dockerfile ./pgbouncer
docker push livingdocs/pgbouncer
```

### livingdocs/certbot-route53-postgres

On Docker Hub: https://hub.docker.com/r/livingdocs/certbot-route53-postgres

Build:
```sh
docker build -t livingdocs/certbot-route53-postgres - < certbot-route53-postgres.Dockerfile

docker push livingdocs/certbot-route53-postgres
```

### livingdocs/letsencrypt

On Docker Hub: https://hub.docker.com/r/livingdocs/letsencrypt

A docker image that sets up a daily cronjob and tries to generate certificates if they need renewal.
Certificates are pushed to an s3 bucket, so they can be fetched from other scripts.

Build:
```sh
docker build -t livingdocs/letsencrypt:1.1 -f ./letsencrypt/Dockerfile ./letsencrypt
docker push livingdocs/letsencrypt:1.1
```


### livingdocs/envoy

On Docker Hub: https://hub.docker.com/r/livingdocs/envoy

The envoy docker image with curl, nano and jq, envsubst and [oidc filter](https://github.com/dgn/oidc-filter).

Build:
```sh
docker build -t livingdocs/envoy:v1.24.0 -f ./envoy/Dockerfile ./envoy
docker push livingdocs/envoy:v1.24.0
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
```

Use:
```sh
docker run --name elasticsearch7 -p 9200:9200 -e 'discovery.type=single-node' livingdocs/elasticsearch:7.10.2
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
docker build -t livingdocs/file-change-hook:1.0 -f ./file-change-hook/Dockerfile ./file-change-hook
docker push livingdocs/file-change-hook:1.0
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
