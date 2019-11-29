# docker build -t livingdocs/docker-node:19-12 - < Dockerfile.docker-node
FROM docker:19
RUN apk add --no-cache curl git tini nano && \
    apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main npm
