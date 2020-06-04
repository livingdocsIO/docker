# docker build -f ./livingdocs-editor-base/12.Dockerfile -t livingdocs/editor-base:12.0 .
# The `12` matches the node version, the `0` in the version defines our version nr
FROM livingdocs/node:12
RUN apk --no-cache add chromium
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_PATH=/usr/lib/chromium/
