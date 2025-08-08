#!/bin/bash
set -Eeuo pipefail

help () {
  if [ "${1:-}" != "" ]; then echo -e "Missing environment variable $1\n" 2>&1; fi

  echo -e "
Using an auth query (default):
  odyssey /etc/odyssey.conf

Proxy only one database:
  This is usually used next to your application as sidecar.
  Just configure the environment variables and use the 'proxy' command.

  DATABASE_HOST=postgres \\
  DATABASE_NAME=someapp \\
  DATABASE_USER=someapp \\
  DATABASE_PASSWORD=somepass \\
  proxy
" 2>&1
  exit 1
}

first=${1:-}
if [ "$first" == "odyssey" ]; then
  exec "$@"
fi
echo $first
if [ "$first" == "proxy" ]; then
  [ "${DATABASE_PORT:-}" == "" ] && export DATABASE_PORT=5432
  [ "${DATABASE_HOST:-}" == "" ] && help DATABASE_HOST
  [ "${DATABASE_NAME:-}" == "" ] && help DATABASE_NAME
  [ "${DATABASE_USER:-}" == "" ] && help DATABASE_USER
  [ "${DATABASE_PASSWORD:-}" == "" ] && help DATABASE_PASSWORD
  envsubst < "${2:-/etc/odyssey/odyssey.proxy.conf}" > "/tmp/odyssey.conf"
  exec odyssey /tmp/odyssey.conf
fi

exec "$@"
