# Usage:
#   FROM livingdocs/server-base:24
#   ADD .npmrc package*.json /app/
#   RUN npm ci
#   ADD . /app
FROM livingdocs/node:24
RUN apk add --no-cache screen
ADD ./wait-for-services /bin/wait-for-services
