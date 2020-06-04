# docker build -f ./livingdocs-editor-base/14.Dockerfile -t livingdocs/editor-base:14.0 .
# The `14` matches the node version, the `0` in the version defines our version nr
FROM livingdocs/node:14
RUN apk --no-cache add chromium
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_PATH=/usr/lib/chromium/
