#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
  set -o xtrace
fi

echo "Setting timezone..."
TZ=${TZ:-UTC}
ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime
echo "${TZ}" > /etc/timezone

echo "Setting up host keys..."
hostkeys_dir=/etc/ssh/hostkeys.d
mkdir -p ${hostkeys_dir}
for t in ed25519 rsa-sha2-256 rsa-sha2-512; do
  file_name="${hostkeys_dir}/ssh_host_${t}_key"
  if [ ! -f $file_name ] || [ ! -f $file_name".pub" ]; then
    echo "Generating ${t} host key"
    rm -f "${file_name}" "${file_name}.pub"
    ssh-keygen -t $t -h -q -N "" -C "" -f "$file_name"
    chmod 0600 "${file_name}"
  fi
done

echo "Setting up users..."
keys_dir=/etc/ssh/keys.d
mkdir -p ${keys_dir}
echo "Creating users..."
jq -r 'keys_unsorted[]' ${keys_dir}/authorized_keys.json | while read -r u; do
  echo "Creating user ${u}"
  adduser -D -H -s /sbin/nologin "${u}"
  sed -i s/"${u}:!"/"${u}:*"/g /etc/shadow
done

echo "Creating sshd configuration..."
envsubst < /etc/ssh/sshd_config_template > /etc/ssh/sshd_config_envsubst
mv /etc/ssh/sshd_config_envsubst /etc/ssh/sshd_config

echo  "Running syslog..."
rsyslogd

if [[ "${ENDLESSH_PORT}" -ne "0" ]]; then
  echo "Running endlessh server..."
  /usr/local/bin/endlessh -p "${ENDLESSH_PORT}" -v &
fi

echo "Running SSH server..."
/usr/sbin/sshd -D -f /etc/ssh/sshd_config -p "${SSHD_PORT}"
