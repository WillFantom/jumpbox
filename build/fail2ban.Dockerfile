FROM alpine:3.17

RUN apk add --no-cache --progress --quiet \
  bash \
  fail2ban \
  ipset \
  iptables \
  ip6tables \
  kmod \
  nftables \
  tzdata

RUN rm -r /etc/fail2ban/jail.d/*
COPY fail2ban/sshd.conf /etc/fail2ban/jail.d/sshd.conf

COPY build/fail2ban.entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV TZ=Europe/London
ENV SSHD_PORT=2222

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
