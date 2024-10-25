FROM livingdocs/node:22

USER root

RUN apk update && \
  apk add gcompat && \
  ln -s /lib/libc.so.6 /usr/lib/libresolv.so.2 && \
  wget -O azcopy.tar.gz https://aka.ms/downloadazcopy-v10-linux && \
  tar -xf azcopy.tar.gz && \
  mv ./azcopy_linux_amd64_*/azcopy /usr/bin/azcopy && \
  chmod +x /usr/bin/azcopy && \
  rm -rf azcopy.tar.gz azcopy_linux_amd64_*

ENTRYPOINT [ "/usr/local/bin/entrypoint" ]
