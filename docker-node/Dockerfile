FROM docker:23.0.3-dind
ADD https://github.com/docker/buildx/releases/download/v0.10.4/buildx-v0.10.4.linux-amd64 /root/.docker/cli-plugins/docker-buildx
ADD https://github.com/regclient/regclient/releases/download/v0.4.7/regctl-linux-amd64 /usr/local/bin/regctl
ADD ./* /usr/local/bin/

USER root

RUN apk add --no-cache curl git tini nano bash jq sed npm && \
  mkdir /root/.ssh && \
  echo '{"experimental": "enabled"}' > /root/.docker/daemon.json && \
  chmod a+x /root/.docker/cli-plugins/docker-buildx /usr/local/bin/regctl && \
  chown -R root:root /root/.docker /root/.ssh

ENV PATH $PATH:./node_modules/.bin
ENV DOCKER_BUILDKIT 1
ENV DOCKER_CONFIG /root/.docker/

ENTRYPOINT [ "/usr/local/bin/entrypoint" ]
