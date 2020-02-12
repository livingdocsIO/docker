FROM alpine:3.11

RUN apk add --no-cache bash curl postgresql-client pgbouncer && \
  mkdir -p ./lego-cli && cd ./lego-cli && curl -L https://github.com/go-acme/lego/releases/download/v3.3.0/lego_v3.3.0_linux_amd64.tar.gz | tar zx && mv ./lego /usr/bin/lego && cd .. && rm -Rf ./lego-cli

ADD ./entrypoint ./letsencrypt-certificate /
RUN adduser --disabled-password --no-create-home pgbouncer

EXPOSE 5432
CMD ["/entrypoint"]
