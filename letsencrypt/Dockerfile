FROM livingdocs/node:14

RUN apk add --no-cache bash jq && \
  apk add --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community --no-cache lego aws-cli

ADD ./entrypoint ./letsencrypt /
ADD ./package.json ./package-lock.json /app
RUN npm ci
ADD ./index.js /app
CMD ["/entrypoint"]
