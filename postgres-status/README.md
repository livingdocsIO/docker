# postgres-status

`postgres-status` is an http server, that serves a healthcheck endpoint for postgres that can be used in a loadbalancer to run queries against a specific postgres instance, be it a primary or replica.

```bash
# Connect to postgres using the DATABASE_URL environment variable
docker run -p 2345:2345 -e DATABASE_URL='postgres://postgres:somepassword@localhost:5432/postgres' livingdocs/postgres-status

# Or use the libpq PGHOST environment variables
docker run -p 2345:2345 --volumes-from=postgres -e PGHOST=/var/run/postgresql livingdocs/postgres-status
```

### http://localhost:2345?target_session_attrs=any

```bash
# If postgres is not available, it will serve a 503 error.
$ curl localhost:2345
{"statusCode":503,"error":"dial tcp 127.0.0.1:5432: connect: connection refused"}

# If the postgres instance is available, it will serve
# booleans about the node type with a statusCode 200
curl localhost:2345
{"statusCode":200,"primary":true,"replica":false,"readonly":false}
```

### http://localhost:2345?target_session_attrs=read-write

```bash
# If you provide a `target_session_attrs=read-write`,
# it will serve a 200 status code on the primary.
curl 'localhost:2345?target_session_attrs=read-write'
{"statusCode":200,"primary":true,"replica":false,"readonly":false}

# and a 503 on a slave
curl 'localhost:2345?target_session_attrs=read-write'
{"statusCode":503,"primary":false,"replica":true,"readonly":true}
```

### http://localhost:2345?target_session_attrs=read-only

```bash
# If you provide a `target_session_attrs=read-only`,
# it will serve a 200 status code on a replica.
curl 'localhost:2345?target_session_attrs=read-only'
{"statusCode":200,"primary":true,"replica":false,"readonly":false}

# and a 503 on a primary
curl 'localhost:2345?target_session_attrs=read-only'
{"statusCode":503,"primary":true,"replica":false,"readonly":false}
```
