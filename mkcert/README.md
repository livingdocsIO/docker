# [livingdocs/mkcert](https://github.com/livingdocsIO/docker/mkcert) ​ ​ ​​[<img src="https://www.docker.com/wp-content/uploads/2022/03/horizontal-logo-monochromatic-white.png" alt="drawing" width="60"/>](https://hub.docker.com/r/livingdocs/mkcert)



A small wrapper around mkcert, that writes server and client certificates.
Supports running in drone as plugin.

```bash
docker run -e DOMAIN="localhost" DESTINATION="cert" -v $PWD:$PWD -w $PWD --rm -it livingdocs/mkcert

# Writes the following files in ./cert
# localhost.ca.cert localhost.ca.key localhost.cert localhost.client.cert localhost.client.key localhost.key
```

You can also run it as drone plugin:
```yaml
steps:
- name: mkcert
  image: livingdocs/mkcert:1.4.4
  settings:
    domain: redis
    destination: ./redis-cert
```
