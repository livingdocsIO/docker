FROM node:18-alpine3.15
RUN apk add --no-cache bash curl git tini nano
WORKDIR /app
ENV NPM_CONFIG_LOGLEVEL warn
ENV PATH $PATH:/app/node_modules/.bin
ENTRYPOINT ["/sbin/tini", "--"]
