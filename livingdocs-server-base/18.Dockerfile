# Usage:
#   FROM livingdocs/server-base:18
#   ADD .npmrc package*.json /app/
#   RUN npm ci
#   ADD . /app
FROM livingdocs/node:18
RUN apk add --no-cache imagemagick

ADD ./wait-for-services /bin/wait-for-services
ADD ./imagemagick-policy.xml /etc/ImageMagick-7/policy.livingdocs.xml

RUN cp /etc/ImageMagick-7/policy.xml /etc/ImageMagick-7/policy.original.xml \
  && cp /etc/ImageMagick-7/policy.livingdocs.xml /etc/ImageMagick-7/policy.xml
