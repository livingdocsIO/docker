# Usage:
#   FROM livingdocs/server-base:26
#   ADD .npmrc package*.json /app/
#   RUN npm ci
#   ADD . /app
ARG VERSION=26
FROM livingdocs/node:${VERSION}
ADD ./wait-for-services /bin/wait-for-services
