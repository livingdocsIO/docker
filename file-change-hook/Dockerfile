FROM alpine
ADD ./entrypoint /entrypoint
RUN apk add bash jq bind-tools curl
ENTRYPOINT [ "/entrypoint" ]
