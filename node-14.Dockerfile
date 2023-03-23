FROM node:14-alpine
RUN apk add --no-cache bash curl git tini nano && npm i -g npm@7 && mkdir /app
WORKDIR /app
ENV NPM_CONFIG_LOGLEVEL warn
ENV PATH $PATH:/app/node_modules/.bin
ENTRYPOINT ["/sbin/tini", "--"]
