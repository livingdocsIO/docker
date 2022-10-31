FROM docker:22.06.0-beta.0-dind
ADD https://github.com/docker/buildx/releases/download/v0.9.1/buildx-v0.9.1.linux-amd64 /root/.docker/cli-plugins/docker-buildx
ADD https://github.com/regclient/regclient/releases/download/v0.4.5/regctl-linux-amd64 /usr/local/bin/regctl

RUN apk add --no-cache curl git tini nano bash jq sed npm && \
    mkdir -p /root/.docker && echo '{"experimental": "enabled"}' > /root/.docker/config.json && \
    chmod a+x /root/.docker/cli-plugins/docker-buildx /usr/local/bin/regctl

ADD ./* /usr/local/bin/
ENV PATH $PATH:./node_modules/.bin
ENV DOCKER_BUILDKIT 1
ENV DOCKER_CONFIG /root/.docker/
ENTRYPOINT [ "/usr/local/bin/entrypoint" ]
