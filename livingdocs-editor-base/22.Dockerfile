# docker build -f ./livingdocs-editor-base/22.Dockerfile -t livingdocs/editor-base:22.0 .
# The `22` matches the node version, the `0` in the version defines our version nr
ARG VERSION=22
FROM livingdocs/node:${VERSION}
RUN apk --no-cache add chromium
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_PATH=/usr/lib/chromium/
