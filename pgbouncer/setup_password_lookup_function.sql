CREATE ROLE role_pgbouncer NOLOGIN NOINHERIT;
CREATE ROLE user_pgbouncer WITH LOGIN ENCRYPTED PASSWORD 'some-password' INHERIT;
GRANT role_pgbouncer to user_pgbouncer;

CREATE OR REPLACE FUNCTION public.pgbouncer_lookup_user(
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
REVOKE EXECUTE ON FUNCTION public.pgbouncer_lookup_user(name) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.pgbouncer_lookup_user(name) TO role_pgbouncer;
