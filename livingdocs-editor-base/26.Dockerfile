# docker build -f ./livingdocs-editor-base/26.Dockerfile -t livingdocs/editor-base:26.0 ./livingdocs-editor-base
# The `26` matches the node version, the `0` in the version defines our version nr.
# Pass --build-arg VERSION=26-pc to build the pointer-compression (pc) variant.
ARG VERSION=26
FROM livingdocs/node:${VERSION}
RUN apk --no-cache add chromium
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_PATH=/usr/lib/chromium/
