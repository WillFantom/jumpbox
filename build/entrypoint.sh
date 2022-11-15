#!/bin/ash
set -e

echo "Setting up host keys..."
hostkeys_dir=/etc/ssh/hostkeys.d
mkdir -p ${hostkeys_dir}
for t in ecdsa ed25519 rsa; do
  file_name="${hostkeys_dir}/ssh_host_${t}_key"
  if [ ! -f $file_name ] || [ ! -f $file_name".pub" ]; then
    echo "Generating ${t} host key"
    rm -f "${file_name}" "${file_name}.pub"
    ssh-keygen -t $t -h -q -N "" -C "" -f "$file_name"
  fi
done

echo "Setting up users..."
keys_dir=/etc/ssh/keys.d
mkdir -p ${keys_dir}
echo "Creating users..."
jq -r 'keys_unsorted[]' ${keys_dir}/authorized_keys.json | while read u; do
  echo "Creating user ${u}"
  adduser -D -H -s /sbin/nologin "${u}"
  sed -i s/${u}:!/"${u}:*"/g /etc/shadow
done

echo "Creating sshd configuration..."
envsubst < /etc/ssh/sshd_config_template > /etc/ssh/sshd_config_envsubst
mv /etc/ssh/sshd_config_envsubst /etc/ssh/sshd_config

if [[ ${ENDLESSH_PORT} -ne "0" ]]; then
  echo "Running endlessh server..."
  /usr/local/bin/endlessh -p ${ENDLESSH_PORT} -v &
fi

echo "Running SSH server..."
/usr/sbin/sshd -D -f /etc/ssh/sshd_config -e -p ${SSHD_PORT}
