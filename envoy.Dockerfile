FROM envoyproxy/envoy-alpine:v1.16.1
USER root
ENV ENVOY_UID=0 ENVOY_GID=0
RUN apk add curl nano jq
