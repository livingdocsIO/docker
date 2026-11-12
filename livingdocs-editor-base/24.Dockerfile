# docker build -f ./livingdocs-editor-base/24.Dockerfile -t livingdocs/editor-base:24.0 ./livingdocs-editor-base
# The `24` matches the node version, the `0` in the version defines our version nr
ARG VERSION=24
FROM livingdocs/node:${VERSION}
RUN apk --no-cache add chromium
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_PATH=/usr/lib/chromium/
