FROM alpine:3.18 as endlessh-builder

RUN apk add --no-cache build-base git
WORKDIR /src
ARG ENDLESSH_VERSION=1.1
RUN git clone -b ${ENDLESSH_VERSION} https://github.com/skeeto/endlessh .
RUN make


FROM alpine:3.18

RUN apk add --no-cache --progress --quiet \
  bash \
  curl \
  gettext \
  jq \
  openssh-server \
  rsyslog \
  shadow \
  tzdata

RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

COPY --from=endlessh-builder /src/endlessh /usr/local/bin/endlessh

COPY sshd/authorized_keys.sh /etc/ssh/authorized_keys.sh
RUN chmod 755 /etc/ssh/authorized_keys.sh

COPY build/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY sshd/banner /etc/ssh/banner
COPY sshd/sshd_config /etc/ssh/sshd_config_template
COPY keys/authorized_keys.json /etc/ssh/keys.d/authorized_keys.json
RUN chown nobody:nogroup /etc/ssh/keys.d/authorized_keys.json

ENV TZ=Europe/London
ENV SSHD_PORT=2222
ENV ENDLESSH_PORT=22

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
