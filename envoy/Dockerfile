FROM envoyproxy/envoy:v1.31.0
ADD ./oidc.wasm /var/local/lib/wasm-filters/oidc.wasm
ADD ./entrypoint /entrypoint
ADD envoy.yaml /etc/envoy/envoy.yaml
RUN apt-get update && apt-get upgrade -yyyy && \
  apt-get install -yyyy curl nano jq gettext-base && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/entrypoint"]
CMD [ ]
