FROM node:24.22.1-alpine3.23
RUN apk add --no-cache bash curl git nano && mkdir /app
WORKDIR /app
ENV NPM_CONFIG_LOGLEVEL=warn
ENV PATH=$PATH:/app/node_modules/.bin
