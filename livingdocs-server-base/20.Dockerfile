# Usage:
#   FROM livingdocs/server-base:20
#   ADD .npmrc package*.json /app/
#   RUN npm ci
#   ADD . /app
FROM livingdocs/node:20
ADD ./wait-for-services /bin/wait-for-services
