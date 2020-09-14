FROM golang:1.13.10-alpine3.11 as go
RUN apk add git
ADD . /go/src/postgres-status
RUN cd /go/src/postgres-status && go get
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -tags netgo -ldflags '-w' -o /go/bin/postgres-status /go/src/postgres-status/main.go

FROM scratch
ENV PGUSER=postgres PORT=2345
USER 1000:1000
COPY --from=go /go/bin/* /bin/
CMD ["/bin/postgres-status"]
