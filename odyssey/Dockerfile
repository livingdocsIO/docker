# docker build -t livingdocs/odyssey:1.3 . -f debian.Dockerfile
# docker run --rm -p 6543:6543 livingdocs/odyssey:1.3
FROM debian:bullseye as builder
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt update && apt install -y curl gnupg && \
  echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
  sh -c 'curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/postgres.gpg' && \
  apt update && apt install -y --no-install-recommends build-essential cmake git libssl-dev openssl libpam0g-dev postgresql-14 gcc gdb libpam0g-dev valgrind libpq5 libpq-dev postgresql-common postgresql-server-dev-14

RUN git clone --depth 1 --branch=1.3 https://github.com/yandex/odyssey.git /tmp/odyssey
WORKDIR /tmp/odyssey
RUN cmake -S $PWD -Bbuild -DCMAKE_BUILD_TYPE=Release -DCC_FLAGS="-Wextra -Wstrict-aliasing" -DUSE_SCRAM=YES
RUN make -Cbuild -j8
# RUN make build_release

# Odyssey on alpine linux has tls issues I wasn't able to solve
# So sadly we need to use debian, which results in a much bigger image
# But at least ssl is now working properly.
# Issue on github: https://github.com/yandex/odyssey/issues/134
# Alpine linux package which also doesn't work
#   tests are disabled there: https://git.alpinelinux.org/aports/tree/testing/odyssey/APKBUILD#n11
FROM debian:bullseye-slim
RUN apt-get update && apt-get upgrade -y && \
  apt-get -y install --no-install-recommends libssl1.1 ca-certificates libpam0g gettext-base && \
  apt-get clean autoclean && apt-get autoremove --yes && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  adduser --uid 1000 --no-create-home --disabled-password --gecos '' odyssey

COPY --from=builder /tmp/odyssey/build/sources/odyssey /usr/local/bin/odyssey
COPY ./entrypoint.sh /entrypoint.sh
COPY odyssey.conf odyssey.proxy.conf setup_password_lookup_function.sh /etc/odyssey/
EXPOSE 6543
USER odyssey
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odyssey", "/etc/odyssey/odyssey.conf"]
