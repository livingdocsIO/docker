# docker run --name=pgbouncer -d -e PGBOUNCER_UPSTREAM_USER=user_pgbouncer -e PGBOUNCER_UPSTREAM_PASSWORD=md58b9ad77b2409cd985b672a95d652b369 -e PGBOUNCER_UPSTREAM='host=172.17.0.1 port=5432' -p 5433:5432 livingdocs/pgbouncer

# Execute this in the template1 database
CREATE SCHEMA pooler;
REVOKE ALL PRIVILEGES ON SCHEMA pooler FROM PUBLIC;

CREATE ROLE role_pgbouncer NOLOGIN NOINHERIT;
CREATE ROLE user_pgbouncer WITH LOGIN ENCRYPTED PASSWORD 'some-password' INHERIT;
GRANT role_pgbouncer to user_pgbouncer;

# And this for every existing database and in the template1 database
CREATE OR REPLACE FUNCTION pooler.pooler_lookup_user(
  in i_username text,
  in i_excludename text,
  out uname text,
  out phash text
) RETURNS record AS $$
  BEGIN
    SELECT usename, passwd FROM pg_catalog.pg_shadow
    WHERE usename = i_username
      AND usename <> i_excludename
    INTO uname, phash;
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- make sure only "role_pgbouncer" can use the function
REVOKE ALL ON FUNCTION pooler.pooler_lookup_user(text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION pooler.pooler_lookup_user(text, text) TO role_pgbouncer;
