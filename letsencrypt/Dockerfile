FROM alpine:3.11

RUN apk add --no-cache bash jq && \
  apk add --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community --no-cache lego aws-cli

ADD ./entrypoint ./letsencrypt /
CMD ["/entrypoint"]
