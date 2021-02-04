FROM envoyproxy/envoy-alpine:v1.17.0
USER root
ENV ENVOY_UID=0 ENVOY_GID=0
RUN apk add curl nano jq
