FROM alpine
RUN apk add mkcert --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
ADD ./drone /usr/local/bin/drone
ENTRYPOINT ["/usr/local/bin/drone"]
