# postgres-status

`postgres-status` is an http server, that serves a healthcheck endpoint for postgres that can be used in a loadbalancer to run queries against a specific postgres instance, be it a primary or replica.

```
docker run -p 8000:8000 \
  -e DATABASE_URL='postgres://postgres:somepassword@localhost:5432/postgres' \
  livingdocs/postgres-status
```

### http://localhost:8000

```bash
# If postgres is not available, it will serve a 503 error.
$ curl localhost:8000
{"statusCode":503,"error":"Service Unavailable"}

# If the postgres instance is available, it will serve
# booleans about the node type with a statusCode 200
curl localhost:8000
{"statusCode":200,"primary":true,"replica":false,"readonly":false}
```

### http://localhost:8000?target_session_attrs=read-write

```bash
# If you provide a `target_session_attrs=read-write`,
# it will serve a 200 status code on the primary.
curl 'localhost:8000?target_session_attrs=read-write'
{"statusCode":200,"primary":true,"replica":false,"readonly":false}

# and a 503 on a slave
curl 'localhost:8000?target_session_attrs=read-write'
{"statusCode":503,"primary":false,"replica":true,"readonly":true}
```

### http://localhost:8000?target_session_attrs=read-only

```bash
# If you provide a `target_session_attrs=read-only`,
# it will serve a 200 status code on a replica.
curl 'localhost:8000?target_session_attrs=read-only'
{"statusCode":200,"primary":true,"replica":false,"readonly":false}

# and a 503 on a primary
curl 'localhost:8000?target_session_attrs=read-only'
{"statusCode":503,"primary":true,"replica":false,"readonly":false}
```
