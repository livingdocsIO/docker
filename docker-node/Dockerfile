FROM docker:20.10.8-dind
ADD ./* /usr/local/sbin/
ADD https://github.com/docker/buildx/releases/download/v0.6.2/buildx-v0.6.2.linux-amd64 /root/.docker/cli-plugins/docker-buildx
ADD https://github.com/regclient/regclient/releases/download/v0.3.7/regctl-linux-amd64 /usr/local/sbin/regctl

RUN apk add --no-cache curl git tini nano bash jq sed npm && \
    mkdir -p /root/.docker && echo '{"experimental": "enabled"}' > /root/.docker/config.json && \
    chmod a+x /root/.docker/cli-plugins/docker-buildx /usr/local/sbin/regctl

ENV PATH $PATH:./node_modules/.bin
ENV DOCKER_BUILDKIT 1
ENV DOCKER_CONFIG /root/.docker/
ENTRYPOINT [ "/usr/local/sbin/entrypoint" ]
