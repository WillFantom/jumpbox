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

echo "Configuring fail2ban..."
sed -i "s/port = ssh/port = ${SSHD_PORT}/g" /etc/fail2ban/jail.d/sshd.conf

echo "Running fail2ban..."
fail2ban-server -x -v -f start
