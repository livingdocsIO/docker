FROM node:20-alpine3.21
RUN apk add --no-cache bash curl git tini nano && mkdir /app
WORKDIR /app
ENV NPM_CONFIG_LOGLEVEL warn
ENV PATH $PATH:/app/node_modules/.bin
ENTRYPOINT ["/sbin/tini", "--"]
