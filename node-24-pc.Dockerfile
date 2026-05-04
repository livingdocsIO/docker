FROM node:24-alpine3.22 AS node-24-alpine

# This build script has 5 differences compared to the original build script
# 1. It enables pointer compression using ./configure --experimental-enable-pointer-compression
# 2. Set WORKDIR /app and create that directory
# 3. Set variables ENV NPM_CONFIG_LOGLEVEL=warn PATH=$PATH:/app/node_modules/.bin
# 4. Add curl, git & nano to container
# 5. does not ship with yarn

FROM alpine:3.22 as builder
ENV NODE_VERSION 24.15.0

RUN apk add --no-cache build-base git python3 curl linux-headers openssl-dev ccache bash procps
WORKDIR /build
RUN git clone --depth 1 --branch v${NODE_VERSION} https://github.com/nodejs/node.git .
RUN ./configure --experimental-enable-pointer-compression --prefix=/usr/local
RUN make -j2
RUN make install DESTDIR=/node-install

# =============================================================================
# Stage 2: Runtime image
# =============================================================================
FROM alpine:3.22

# Install only runtime dependencies
RUN apk add --no-cache ca-certificates libssl3 libstdc++ libgcc bash curl git nano && \
  mkdir /app && addgroup -g 1000 node && \
  adduser -u 1000 -G node -s /bin/sh -D node

COPY --from=builder /node-install/usr/local /usr/local
COPY --from=node-24-alpine /usr/local/bin/docker-entrypoint.sh /usr/local/bin
WORKDIR /app
ENV NPM_CONFIG_LOGLEVEL=warn PATH=$PATH:/app/node_modules/.bin

ENTRYPOINT ["docker-entrypoint.sh"]
CMD [ "node" ]
