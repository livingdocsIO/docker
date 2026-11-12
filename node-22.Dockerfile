FROM node:22.23.5-alpine3.23
RUN apk add --no-cache bash curl git nano && mkdir /app
WORKDIR /app
ENV NPM_CONFIG_LOGLEVEL=warn PATH=$PATH:/app/node_modules/.bin
