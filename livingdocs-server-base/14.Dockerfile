# tag: livingdocs/server-base:14.0
# Usage:
#   FROM livingdocs/server-base:14.0
#   ADD .npmrc package*.json /app/
#   RUN npm ci
#   ADD . /app
FROM livingdocs/node:14.0
RUN apk add --no-cache imagemagick && \
  apk add --no-cache --virtual build-deps python alpine-sdk autoconf libtool automake && \
  mkdir -p /prebuilds && cd /prebuilds && npm init -y && npm install sodium-native@3.1.1 && \
  apk del build-deps

ENV SODIUM_NATIVE_PREBUILD=/prebuilds/node_modules/sodium-native/
ADD ./wait-for-services /bin/wait-for-services
ADD ./imagemagick-policy.xml /etc/ImageMagick-7/policy.livingdocs.xml

RUN cp /etc/ImageMagick-7/policy.xml /etc/ImageMagick-7/policy.original.xml \
  && cp /etc/ImageMagick-7/policy.livingdocs.xml /etc/ImageMagick-7/policy.xml
