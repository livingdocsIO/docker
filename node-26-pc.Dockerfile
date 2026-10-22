FROM node:26-alpine3.23 AS node-26-alpine

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
ENV NODE_VERSION=26.12.1 RUST_VERSION=1.91.1

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

# Rust builds Temporal; host toolchain and target std must come from the same rustc build
RUN <<'EOF'
set -e
sha() {
  case "$1" in
    rust-x86_64) echo 2fc7cac1663d245530bca0d487b2423f6b5a0bb99f03eedc439a155484dd6f56 ;;
    rust-aarch64) echo 4b70475786f0e195cc5e6d3de57fafb334de7ed612555921eb78668fdfae6133 ;;
    rust-std-x86_64) echo 4066d5dce6017dcd116c75972b3ec6c26fe5a1fa59f02a1da9e127d1f4a1aa7f ;;
    rust-std-aarch64) echo 2a919a0e5df46e1bfe4b8be8fbc81cf48bf9813be34ff5f212a2a68f03eb517f ;;
  esac
}
fetch() {
  name=$1-$RUST_VERSION-$2-unknown-linux-musl
  curl -fsSL -o /tmp/$name.tar.xz https://static.rust-lang.org/dist/$name.tar.xz
  echo "$(sha $1-$2)  /tmp/$name.tar.xz" | sha256sum -c -
  xz -dc /tmp/$name.tar.xz | tar -x -C /tmp
  shift 2
  /tmp/$name/install.sh --prefix=/opt/rust --disable-ldconfig "$@"
  rm -rf /tmp/$name /tmp/$name.tar.xz
}
host=$(triple $BUILDARCH)
fetch rust $host --components=rustc,cargo,rust-std-$host-unknown-linux-musl
[ "$BUILDARCH" = "$TARGETARCH" ] || fetch rust-std $(triple $TARGETARCH)
EOF

# gyp runs one cargo action for the host and target toolsets; build the crates for both triples
COPY --chmod=755 <<'EOF' /usr/local/bin/cargo
#!/bin/sh
set -e
host=$(triple $BUILDARCH)-unknown-linux-musl
target=$(triple $TARGETARCH)-unknown-linux-musl
case " $* " in *" --target-dir "*) ;; *) exec /opt/rust/bin/cargo "$@" ;; esac
[ "$host" = "$target" ] && exec /opt/rust/bin/cargo "$@"
targetdir=$(printf '%s\n' "$@" | sed -n '/^--target-dir$/{n;p;}')
/opt/rust/bin/cargo "$@" --target "$host"
/opt/rust/bin/cargo "$@" --target "$target"
for profile in release debug; do
  if [ -f "$targetdir/$target/$profile/libnode_crates.a" ]; then
    mkdir -p "$targetdir/$profile"
    cp "$targetdir/$target/$profile/libnode_crates.a" "$targetdir/$profile/"
  fi
done
EOF
ENV PATH=$PATH:/opt/rust/bin CARGO_HOME=/opt/cargo

WORKDIR /build
RUN git clone --depth 1 --branch v${NODE_VERSION} https://github.com/nodejs/node.git .

RUN <<'EOF'
set -e
flags="--experimental-enable-pointer-compression --v8-enable-temporal-support --prefix=/usr/local"
if [ "$BUILDARCH" != "$TARGETARCH" ]; then
  t=$(triple $TARGETARCH)
  {
    echo "export CC_host=gcc CXX_host=g++"
    echo "export CC=/opt/cross/bin/$t-linux-musl-gcc"
    echo "export CXX='/opt/cross/bin/$t-linux-musl-g++ -static-libstdc++'"
    echo "export LDFLAGS=-Wl,--build-id=sha1"
  } > /build/cross.env
  mkdir -p /opt/cargo
  printf '[target.%s-unknown-linux-musl]\nlinker = "/opt/cross/bin/%s-linux-musl-gcc"\n' $t $t > /opt/cargo/config.toml
  flags="$flags --dest-os=linux --dest-cpu=$(case $TARGETARCH in amd64) echo x64 ;; *) echo $TARGETARCH ;; esac)"
  python3 - "$(triple $BUILDARCH)" "$t" <<'PY'
import re, sys
host, target = sys.argv[1:]
path = 'deps/crates/crates.gyp'
src = open(path).read()
pattern = re.compile(r"'link_settings':\s*\{\s*'libraries':\s*\[\s*'<\(node_crates_libpath\)',\s*\]", re.S)
replacement = """'link_settings': {
        'target_conditions': [
          ['_toolset=="host"', {'libraries': ['<(SHARED_INTERMEDIATE_DIR)/%s-unknown-linux-musl/release/libnode_crates.a']}],
          ['_toolset=="target"', {'libraries': ['<(SHARED_INTERMEDIATE_DIR)/%s-unknown-linux-musl/release/libnode_crates.a']}],
        ]""" % (host, target)
src, count = pattern.subn(replacement, src, count=1)
assert count == 1, 'crates.gyp link_settings pattern not found'
open(path, 'w').write(src)
PY
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
COPY --from=node-26-alpine /usr/local/bin/docker-entrypoint.sh /usr/local/bin
WORKDIR /app
ENV NPM_CONFIG_LOGLEVEL=warn PATH=$PATH:/app/node_modules/.bin

ENTRYPOINT ["docker-entrypoint.sh"]
CMD [ "node" ]
