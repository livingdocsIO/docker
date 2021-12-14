FROM envoyproxy/envoy-alpine:v1.20.1
ADD ./oidc.wasm /var/local/lib/wasm-filters/oidc.wasm
ADD ./entrypoint /entrypoint
RUN rm /etc/envoy/envoy.yaml && \
  mkdir /home/envoy && chown envoy:envoy /home/envoy && \
  apk add bash curl nano jq && apk add envsubst --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing

ENTRYPOINT ["/entrypoint"]
CMD [ ]
