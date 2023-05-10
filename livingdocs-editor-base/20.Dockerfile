# docker build -f ./livingdocs-editor-base/20.Dockerfile -t livingdocs/editor-base:20.0 .
# The `20` matches the node version, the `0` in the version defines our version nr
FROM livingdocs/node:20
RUN apk --no-cache add chromium
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_PATH=/usr/lib/chromium/
