FROM alpine:3.16

RUN apk add --no-cache curl \
  gettext \
  jq \
  openssh-server \
  shadow

RUN adduser -D -H jumpbox

COPY sshd/authorized_keys.sh /etc/ssh/authorized_keys.sh
RUN chmod 755 /etc/ssh/authorized_keys.sh

COPY build/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY sshd/banner /etc/ssh/banner
COPY sshd/sshd_config /etc/ssh/sshd_config_template

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
