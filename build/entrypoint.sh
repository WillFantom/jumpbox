#!/bin/ash
set -e

echo "Setting up host keys..."
keys_dir=/etc/ssh/keys.d
mkdir -p ${keys_dir}
for t in ecdsa ed25519 rsa; do
  file_name="${keys_dir}/ssh_host_${t}_key"
  if [ ! -f $file_name ]; then
    echo "Generating ${t} host key"
    ssh-keygen -t $t -h -q -N "" -f "$file_name"
  fi
done

echo "Creating users..."
jq -r 'keys_unsorted[]' ${keys_dir}/authorized_keys.json | while read u; do
  echo "Creating user ${u}"
  adduser -D -H -s /sbin/nologin "${u}"
  sed -i s/${u}:!/"${u}:*"/g /etc/shadow
done

echo "Creating sshd configuration..."
envsubst < /etc/ssh/sshd_config_template > /etc/ssh/sshd_config_envsubst
mv /etc/ssh/sshd_config_envsubst /etc/ssh/sshd_config

echo "Running SSH server..."
/usr/sbin/sshd -D -f /etc/ssh/sshd_config -e -p 2222