FROM wrouesnel/postgres_exporter:v0.8.0 as exporter

FROM alpine
RUN apk add --no-cache curl nano
COPY postgres_exporter_queries.yml /postgres_exporter_queries.yml
COPY --from=exporter /postgres_exporter /postgres_exporter
CMD ["/postgres_exporter", "--extend.query-path=/postgres_exporter_queries.yml"]
ENTRYPOINT []
