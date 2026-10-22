FROM node:24-alpine3.23 AS node-24-alpine

# This build script has 5 differences compared to the original build script
# 1. It enables pointer compression using ./configure --experimental-enable-pointer-compression
# 2. Set WORKDIR /app and create that directory
# 3. Set variables ENV NPM_CONFIG_LOGLEVEL=warn PATH=$PATH:/app/node_modules/.bin
# 4. Add curl, git & nano to container
# 5. does not ship with yarn
#
# Node is compiled on the build platform. Other target architectures are cross-compiled
# with a musl toolchain, like https://github.com/nodejs/unofficial-builds/tree/main/recipes/arm64-musl

FROM --platform=$BUILDPLATFORM alpine:3.23 AS builder
ARG BUILDARCH
ARG TARGETARCH
ENV NODE_VERSION=24.22.1

RUN apk add --no-cache build-base binutils-gold git python3 curl linux-headers bash procps xz rsync bzip2 patch

COPY --chmod=755 <<'EOF' /usr/local/bin/triple
#!/bin/sh
case "$1" in amd64) echo x86_64 ;; arm64) echo aarch64 ;; *) echo "unsupported arch $1" >&2; exit 1 ;; esac
EOF

RUN <<'EOF'
set -e
[ "$BUILDARCH" = "$TARGETARCH" ] && exit 0
release=3635262e4524c991552789af6f36211a335a77b3
cd /tmp
curl -fsSL https://github.com/richfelker/musl-cross-make/archive/$release.tar.gz | tar -xz
cd musl-cross-make-$release
printf 'TARGET = %s-linux-musl\nGCC_VER = 14.2.0\nOUTPUT = /opt/cross\n' "$(triple $TARGETARCH)" > config.mak
make -j$(nproc)
make install
rm -rf /tmp/musl-cross-make-$release
EOF

WORKDIR /build
RUN git clone --depth 1 --branch v${NODE_VERSION} https://github.com/nodejs/node.git .

RUN <<'EOF'
set -e
flags="--experimental-enable-pointer-compression --prefix=/usr/local"
if [ "$BUILDARCH" != "$TARGETARCH" ]; then
  t=$(triple $TARGETARCH)
  {
    echo "export CC_host=gcc CXX_host=g++"
    echo "export CC=/opt/cross/bin/$t-linux-musl-gcc"
    echo "export CXX='/opt/cross/bin/$t-linux-musl-g++ -static-libstdc++'"
    echo "export LDFLAGS=-Wl,--build-id=sha1"
  } > /build/cross.env
  flags="$flags --dest-os=linux --dest-cpu=$(case $TARGETARCH in amd64) echo x64 ;; *) echo $TARGETARCH ;; esac)"
else
  touch /build/cross.env
fi
. /build/cross.env
./configure $flags
EOF

ARG MAKE_JOBS
RUN . /build/cross.env && make -j${MAKE_JOBS:-$(nproc)}
RUN . /build/cross.env && make install DESTDIR=/node-install

# =============================================================================
# Stage 2: Runtime image
# =============================================================================
FROM alpine:3.23

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
