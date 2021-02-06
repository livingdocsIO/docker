FROM alpine
RUN adduser --uid 1000 --no-create-home --disabled-password --gecos '' odyssey && \
  apk add odyssey --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing

COPY ./odyssey.conf ./setup_password_lookup_function.sh /etc/odyssey/
EXPOSE 6543
USER odyssey
CMD ["odyssey", "/etc/odyssey/odyssey.conf"]
