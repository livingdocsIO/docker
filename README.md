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
docker build -t livingdocs/docker-node:19-12 - < ./docker-node/Dockerfile

docker push livingdocs/docker-node:19-12
```

### livingdocs/postgres-exporter

```sh
docker build -t livingdocs/postgres-exporter -f postgres-exporter/Dockerfile ./postgres-exporter

docker push livingdocs/postgres-exporter
```

### livingdocs/certbot-route53-postgres

On Docker Hub: https://hub.docker.com/r/livingdocs/certbot-route53-postgres

Build:
```sh
docker build -t livingdocs/certbot-route53-postgres - < Dockerfile.certbot-route53-postgres

docker push livingdocs/certbot-route53-postgres
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
