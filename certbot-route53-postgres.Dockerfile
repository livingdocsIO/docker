FROM certbot/dns-route53:v0.39.0
RUN apk add --no-cache bash postgresql sudo shadow && usermod -u 999 postgres && usermod -g 999 postgres
ENTRYPOINT []
CMD ["certbot"]
