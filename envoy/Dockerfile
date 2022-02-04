FROM envoyproxy/envoy-alpine:v1.21.0
ADD ./oidc.wasm /var/local/lib/wasm-filters/oidc.wasm
ADD ./entrypoint /entrypoint
RUN rm /etc/envoy/envoy.yaml && \
  mkdir /home/envoy && chown envoy:envoy /home/envoy && \
  apk add bash curl nano jq && apk add envsubst --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing

ENTRYPOINT ["/entrypoint"]
CMD [ ]
