FROM livingdocs/node:14.0
RUN apk add --no-cache imagemagick bash

ADD ./wait-for-services /bin/wait-for-services
ADD ./imagemagick-policy.xml /etc/ImageMagick-7/policy.livingdocs.xml

RUN cp /etc/ImageMagick-7/policy.xml /etc/ImageMagick-7/policy.original.xml \
  && cp /etc/ImageMagick-7/policy.livingdocs.xml /etc/ImageMagick-7/policy.xml

