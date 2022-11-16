#!/bin/ash

# validate the username, sanitizing the lookup next
regex="^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$"
if [[ ! $1 =~ ${regex} ]]; then
  exit 1
fi

# find keys for given user
jq -r -c .${1}'[]' /etc/ssh/keys.d/authorized_keys.json | while read k; do
  echo "$k"
  exit 0
done
