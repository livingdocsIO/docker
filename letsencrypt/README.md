# letsencrypt

A service that's using `lego` to generate multiple ssl certificates using letsencrypt and save them on s3.

Currently the http and route53 dns challenges are supported.

Certificates are synced to syned to s3 and only generated if necessary.
The purpose of this container is only to generate ssl certificates for other services.
The service uses JSON webtokens for authorization to fetch specific certificates using a simple api.


If you're using the http challenge, the port `8080` of this container needs
to be exposed as port 80 and accessible on the path `/.well-known/acme-challenge`, so letsencrypt can
fetch and confirm an initiated "http-challenge"-based letsencrypt request.


```bash
# Once the service is launched
docker run -e JWT_SECRET=foo -e LETSENCRYPT_CERTIFICATES='[{...configFromBelow}]' -p 80:8080 livingdocs/letsencrypt

# Go to jwt.io, and create a token with the following payload: '{"domains":["livingdocs.io"]}'
# Use the secret declared in `JWT_SECRET`
# Then use that token in the http request
curl -H 'Authorization: Bearer JWT' http://localhost/list
> [{"name":"livingdocs.io","cert":"...","key":"..."}]

```


### Configuration
- `JWT_SECRET`: The bearer token to use for http request when requesting certificates.
- `LETSENCRYPT_CERTIFICATES`:  A json array that contains objects of ssl declarations.
  It should be an array of object like [
      {
        "email": "operations@livingdocs.io",
        "hostedZoneID": "Z34P3XXU8M8OBW",
        "domains": [
          "livingdocs.io",
          "*.livingdocs.io",
          "*.production.livingdocs.io"
        ]
      }

    or

      {
        "enabled": true,
        "email": "operations@livingdocs.io",
        "challenge": "http",
        "domains": [
          "www.livingdocs.io",
          "elasticsearch.livingdocs.io"
        ]
      }
