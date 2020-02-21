# Docker

This repo is set up to use automated builds on docker hub.

### livingdocs/node

On Docker Hub: https://hub.docker.com/r/livingdocs/node

```sh
docker build -t livingdocs/node:12.0 - < Dockerfile.node

docker push livingdocs/node:12.0
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

### livingdocs/certbot-route53-postgres

On Docker Hub: https://hub.docker.com/r/livingdocs/certbot-route53-postgres

Build:
```sh
docker build -t livingdocs/certbot-route53-postgres - < Dockerfile.certbot-route53-postgres

docker push livingdocs/certbot-route53-postgres
```

### livingdocs/letsencrypt

On Docker Hub: https://hub.docker.com/r/livingdocs/letsencrypt

A docker image that sets up a daily cronjob and tries to generate certificates if they need renewal.
Certificates are pushed to an s3 bucket, so they can be fetched from other scripts.

Build:
```sh
cd letsencrypt
docker build -t livingdocs/letsencrypt .
docker push livingdocs/letsencrypt
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

```sh
docker build --rm -t livingdocs/elasticsearch:6.8.5 - <<EOF
FROM docker.elastic.co/elasticsearch/elasticsearch-oss:6.8.5
EOF

docker push livingdocs/elasticsearch:6.8.5
```

## Some other useful setups

- Varnish: https://github.com/livingdocsIO/dockerfile-varnish
- Loki & Grafana for a local setup: https://github.com/livingdocsIO/loki
- Squid, the http proxy: https://github.com/livingdocsIO/squid
