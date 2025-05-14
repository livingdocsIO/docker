FROM node:24-alpine3.21
RUN apk add --no-cache bash curl git nano && mkdir /app
WORKDIR /app
ENV NPM_CONFIG_LOGLEVEL warn
ENV PATH $PATH:/app/node_modules/.bin
