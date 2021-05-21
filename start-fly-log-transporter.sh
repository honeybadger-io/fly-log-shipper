#!/bin/bash
set -e
trap 'kill $(jobs -p)' EXIT

[[ ! -z "$DATADOG_API_KEY" ]] && cat /etc/vector/datadog.toml >> /etc/vector/vector.toml
[[ ! -z "$AWS_ACCESS_KEY_ID" ]] && [[ ! -z "$AWS_BUCKET" ]] && cat /etc/vector/aws_s3.toml >> /etc/vector/vector.toml
[[ ! -z "$HONEYCOMB_API_KEY" ]] && cat /etc/vector/honeycomb.toml >> /etc/vector/vector.toml 
[[ ! -z "$HUMIO_TOKEN" ]] && cat /etc/vector/honeycomb.toml >> /etc/vector/vector.toml 
[[ ! -z "$LOGDNA_API_KEY" ]] && cat /etc/vector/logdna.toml >> /etc/vector/vector.toml 
if [ ! -z "$NEW_RELIC_INSERT_KEY" ] || [ ! -z "$NEW_RELIC_LICENSE_KEY" ]; then
  cat /etc/vector/honeycomb.toml >> /etc/vector/vector.toml 
  [[ ! -z "$NEW_RELIC_INSERT_KEY" ]] && echo "  insert_key = \"${NEW_RELIC_INSERT_KEY}\"" >> /etc/vector/vector.toml 
  [[ ! -z "$NEW_RELIC_LICENSE_KEY" ]] && echo "  license_key = \"${NEW_RELIC_LICENSE_KEY}\"" >> /etc/vector/vector.toml 
fi
[[ ! -z "$PAPERTRAIL_ENDPOINT" ]] && cat /etc/vector/papertrail.toml >> /etc/vector/vector.toml 
[[ ! -z "$SEMATEXT_TOKEN" ]] && cat /etc/vector/sematext.toml >> /etc/vector/vector.toml 

vector -c /etc/vector/vector.toml &
while [ ! -e /var/run/vector.sock ]; do
  sleep 0.5
done
/usr/local/bin/fly-logs | socat -u - UNIX-CONNECT:/var/run/vector.sock