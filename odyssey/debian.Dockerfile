# docker run --rm -p 6543:6543 livingdocs/odyssey:1.2-alpha
FROM debian:bullseye as builder
RUN apt update && apt -y install curl gnupg2 build-essential cmake git libssl-dev libpam0g-dev postgresql-server-dev-13
RUN git clone --depth 1 --branch=master https://github.com/yandex/odyssey.git /tmp/odyssey
WORKDIR /tmp/odyssey/build
RUN cmake -DCMAKE_BUILD_TYPE=Release ..
RUN make -j

# Odyssey on alpine linux has tls issues I wasn't able to solve
# So sadly we need to use debian, which results in a much bigger image
# But at least ssl is now working properly.
# Issue on github: https://github.com/yandex/odyssey/issues/134
# Alpine linux package which also doesn't work
#   tests are disabled there: https://git.alpinelinux.org/aports/tree/testing/odyssey/APKBUILD#n11
FROM debian:bullseye-slim
RUN apt-get update && \
  apt-get -y install --no-install-recommends libssl1.1 ca-certificates libpam0g && \
  apt-get clean autoclean && apt-get autoremove --yes && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  adduser --uid 1000 --no-create-home --disabled-password --gecos '' odyssey

COPY --from=builder /tmp/odyssey/build/sources/odyssey /usr/local/bin/odyssey
COPY odyssey.conf setup_password_lookup_function.sh /etc/odyssey/
EXPOSE 6543
USER odyssey
CMD ["odyssey", "/etc/odyssey/odyssey.conf"]
