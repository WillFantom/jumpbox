#!/bin/ash

jq -r -c .${1}'[]' /etc/ssh/keys.d/authorized_keys.json | while read k; do
  echo "$k"
done
