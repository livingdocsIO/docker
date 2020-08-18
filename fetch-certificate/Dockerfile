FROM clux/muslrust as builder
WORKDIR /usr/src/fetch-certificate
COPY . .
RUN rustup target add x86_64-unknown-linux-musl
RUN cargo build --release --target=x86_64-unknown-linux-musl

FROM scratch
USER 1000
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
COPY --from=builder /usr/src/fetch-certificate/target/x86_64-unknown-linux-musl/release/fetch-certificate /usr/local/bin/fetch-certificate
ENTRYPOINT ["/usr/local/bin/fetch-certificate"]
