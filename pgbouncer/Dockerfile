FROM alpine
RUN apk add --no-cache bash curl pgbouncer

ADD ./entrypoint /
RUN adduser --disabled-password --no-create-home pgbouncer

EXPOSE 5432
CMD ["/entrypoint"]
