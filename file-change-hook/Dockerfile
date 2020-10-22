FROM alpine
ADD ./file-change-hook /file-change-hook
RUN apk add bash jq bind-tools curl
ENTRYPOINT [ "/file-change-hook" ]
