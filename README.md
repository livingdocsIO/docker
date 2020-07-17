# Docker

This repo is set up to use automated builds on docker hub.

### livingdocs/node

On Docker Hub: https://hub.docker.com/r/livingdocs/node

```sh
docker build -t livingdocs/node:14.1 -t livingdocs/node:14 - < node-14.Dockerfile
docker build -t livingdocs/node:12.1 -t livingdocs/node:12 - < node-12.Dockerfile

docker push livingdocs/node:14
docker push livingdocs/node:14.1
docker push livingdocs/node:12
docker push livingdocs/node:12.1
```

### livingdocs/server-base

On Docker Hub: https://hub.docker.com/r/livingdocs/server-base

```sh
docker build -f ./livingdocs-server-base/14.Dockerfile -t livingdocs/server-base:14.1 -t livingdocs/server-base:14 ./livingdocs-server-base
docker build -f ./livingdocs-server-base/12.Dockerfile -t livingdocs/server-base:12.3 -t livingdocs/server-base:12 ./livingdocs-server-base
docker push livingdocs/server-base:14
docker push livingdocs/server-base:14.1
docker push livingdocs/server-base:12
docker push livingdocs/server-base:12.3
```

### livingdocs/editor-base

On Docker Hub: https://hub.docker.com/r/livingdocs/editor-base

```sh
docker build -t livingdocs/editor-base:14.1 -t livingdocs/editor-base:14 - < ./livingdocs-editor-base/14.Dockerfile
docker build -t livingdocs/editor-base:12.1 -t livingdocs/editor-base:12 - < ./livingdocs-editor-base/12.Dockerfile
docker push livingdocs/editor-base:14
docker push livingdocs/editor-base:14.1
docker push livingdocs/editor-base:12
docker push livingdocs/editor-base:12.1
```

### livingdocs/docker-node

The official docker image with node, git and curl

On Docker Hub: https://hub.docker.com/r/livingdocs/docker-node

```sh
docker build -t livingdocs/docker-node:19-12 -f ./docker-node/Dockerfile ./docker-node
docker push livingdocs/docker-node:19-12
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
docker build -t livingdocs/odyssey:1.1 - < odyssey.Dockerfile
docker push livingdocs/odyssey:1.1
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

Use:
```sh
docker run -it --rm livindocs/letsencrypt \
  -e JWT_SECRET=F8C1FE7E-10EA-4C4A-8CEB-944FC040A98E \
  -e LETSENCRYPT_CERTIFICATES='[{"email":"operations@livingdocs.io", "domains": ["livingdocs.io"]}]' \
  -e AWS_REGION=eu-central-1 \
  -e AWS_PATH_PREFIX=letsencrypt/ \
  -e AWS_BUCKET=livingdocs \
  -e AWS_ACCESS_KEY_ID=some-aws-access-key \
  -e AWS_SECRET_ACCESS_KEY=some-aws-secret-key
```

### livingdocs/elasticsearch

Build:
```sh
docker pull docker.elastic.co/elasticsearch/elasticsearch-oss:6.8.10
docker pull docker.elastic.co/elasticsearch/elasticsearch-oss:7.8.0
docker tag docker.elastic.co/elasticsearch/elasticsearch-oss:7.8.0 livingdocs/elasticsearch:7.8.0
docker push livingdocs/elasticsearch:6.8.10
docker push livingdocs/elasticsearch:7.8.0
```

Use:
```sh
docker run --name elasticsearch7 -p 9200:9200 -e 'discovery.type=single-node' livingdocs/elasticsearch:7.8.0
```

## Some other useful setups

- Varnish: https://github.com/livingdocsIO/dockerfile-varnish
- Loki & Grafana for a local setup: https://github.com/livingdocsIO/loki
- Squid, the http proxy: https://github.com/livingdocsIO/squid
