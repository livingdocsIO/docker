FROM docker:19-dind
ADD ./entrypoint /entrypoint
ADD ./files-changed /sbin/files-changed
ADD ./docker-login /sbin/docker-login
ADD ./pull-docker-image /sbin/pull-docker-image
ADD ./sanitize-tag /sbin/sanitize-tag
ADD ./push-docker-sha /sbin/push-docker-sha
ADD ./push-docker-tag /sbin/push-docker-tag
ADD ./docker-image-tags /sbin/docker-image-tags
ADD https://github.com/docker/buildx/releases/download/v0.3.1/buildx-v0.3.1.linux-amd64 /root/.docker/cli-plugins/docker-buildx

RUN apk add --no-cache curl git tini nano bash jq sed && \
    apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main npm && \
    mkdir -p /root/.docker && echo '{"experimental": "enabled"}' > /root/.docker/config.json && \
    chmod a+x /root/.docker/cli-plugins/docker-buildx

ENV DOCKER_BUILDKIT 1
ENV DOCKER_CONFIG /root/.docker/
ENTRYPOINT [ "/entrypoint" ]
