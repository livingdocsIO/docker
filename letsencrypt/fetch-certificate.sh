#!/bin/bash
set -eu
URL="${FETCH_CERTIFICATE_URL:-https://certificates.production.livingdocs.io/list}"
TOKEN="${FETCH_CERTIFICATE_TOKEN:-SOME TOKEN}"
FILE="${FETCH_CERTIFICATE_FILE:-<domain>}"

RES=$(curl -s -H "Authorization: Bearer $TOKEN" $URL)
CERTIFICATE=$(jq -rj '.[0]' <<< "$RES")
DOMAIN=$(jq -r '.domain' <<< "$CERTIFICATE")
FILE=$(sed "s/<domain>/$DOMAIN/" <<< "$FILE")

echo Downloaded $FILE.key and $FILE.cert
jq -r '.key' <<< "$CERTIFICATE" > $FILE.key
jq -r '.cert' <<< "$CERTIFICATE" > $FILE.cert
# su postgres -c '/usr/lib/postgresql/11/bin/pg_ctl reload'
