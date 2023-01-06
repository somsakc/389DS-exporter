#
# Stage 1: Intermediate Build
#
FROM ubuntu:22.04 as build

RUN apt update --allow-insecure-repositories && \
    apt install -y git golang-1.18

RUN mkdir -p /tmp/389DS-exporter && \
    cd /tmp/389DS-exporter && \
    git clone https://github.com/somsakc/389DS-exporter.git . && \
    /usr/lib/go-1.18/bin/go mod tidy && \
    /usr/lib/go-1.18/bin/go build -x && \
    cp -v 389DS-exporter /usr/local/bin && \
    chmod -v 555 /usr/local/bin/389DS-exporter && \
    chown -v 1001.1001 /usr/local/bin/389DS-exporter && \
    ls -l /usr/local/bin/389DS-exporter


#
# Stage 2: Final Image
#
FROM ubuntu:22.04

LABEL version="1.0"
LABEL description="Prometheus LDAP exporter container"
LABEL maintainer="somsakc@hotmail.com"
LABEL credits="https://github.com/ozgurcd/389DS-exporter"

COPY --from=build /tmp/389DS-exporter/389DS-exporter /usr/local/bin/389DS-exporter

RUN chmod 555 /usr/local/bin/389DS-exporter && \
    chown 1001.1001 /usr/local/bin/389DS-exporter

EXPOSE 9095

WORKDIR /usr/local/bin
USER 1001

CMD /usr/local/bin/389DS-exporter

