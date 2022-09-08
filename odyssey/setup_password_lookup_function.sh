#!/bin/bash
set -e

POOLER_PASSWORD=$(echo $POOLER_PASSWORD | sed 's/\x27/\x27\x27/')

psql -v ON_ERROR_STOP=1 -d postgres --username "$POSTGRES_USER" <<-EOSQL
CREATE USER pooler WITH ENCRYPTED PASSWORD '${POOLER_PASSWORD}';
CREATE SCHEMA pooler AUTHORIZATION pooler;
GRANT CONNECT ON DATABASE "postgres" TO pooler;

CREATE OR REPLACE FUNCTION pooler.lookup_user(i_usename TEXT, i_ignoreusename TEXT)
RETURNS TABLE(username TEXT, password TEXT) AS
$$
BEGIN
  RETURN QUERY
  SELECT usename::TEXT, passwd::TEXT FROM pg_catalog.pg_shadow
  WHERE usename = i_usename
  AND usename <> i_ignoreusename;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION pooler.lookup_user(i_usename TEXT)
RETURNS TABLE(username TEXT, password TEXT) AS
$$
BEGIN
  RETURN QUERY
  SELECT usename::TEXT, passwd::TEXT FROM pg_catalog.pg_shadow
  WHERE usename = i_usename;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

REVOKE ALL ON FUNCTION pooler.lookup_user(i_usename TEXT, i_ignoreusename TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION pooler.lookup_user(i_usename TEXT, i_ignoreusename TEXT) TO pooler;
REVOKE ALL ON FUNCTION pooler.lookup_user(i_usename TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION pooler.lookup_user(i_usename TEXT) TO pooler;
EOSQL
