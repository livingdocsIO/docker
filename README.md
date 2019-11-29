# Docker

This repo is set up to use automated builds on docker hub.

### livingdocs/node

On Docker Hub: https://hub.docker.com/r/livingdocs/node
Pull: `docker pull livingdocs/node:12.0`

### livingdocs/docker-node

The official docker image with node, git and curl

On Docker Hub: https://hub.docker.com/r/livingdocs/docker-node
Pull: `docker pull livingdocs/docker-node:19-12`


### livingdocs/elasticsearch

```
docker build --rm -t livingdocs/elasticsearch:6.8.5 - <<EOF
FROM docker.elastic.co/elasticsearch/elasticsearch-oss:6.8.5
EOF

docker push livingdocs/elasticsearch:6.8.5
```

## Some other useful setups

- Varnish: https://github.com/livingdocsIO/dockerfile-varnish
- Loki & Grafana for a local setup: https://github.com/livingdocsIO/loki
- Squid, the http proxy: https://github.com/livingdocsIO/squid
