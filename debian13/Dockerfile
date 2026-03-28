ARG NODE
FROM node:${NODE}-trixie-slim

ARG NODE
ARG VERSION=unknown
ARG DATI=unknown
ARG BUILD=0


LABEL org.opencontainers.image.title="Official ioBroker Docker Image" \
    org.opencontainers.image.description="Official Docker image for ioBroker smarthome software (https://www.iobroker.net)" \
    org.opencontainers.image.documentation="https://github.com/buanet/ioBroker.docker#readme" \
    org.opencontainers.image.authors="André Germann <info@buanet.de>" \
    org.opencontainers.image.url="https://github.com/buanet/ioBroker.docker" \
    org.opencontainers.image.source="https://github.com/buanet/ioBroker.docker" \
    org.opencontainers.image.base.name="node:${NODE}-trixie-slim" \
    org.opencontainers.image.version="${VERSION}" \
    org.opencontainers.image.created="${DATI}"

ENV DEBIAN_FRONTEND="noninteractive"

# Install system packages (cached layer)
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -q -y --no-install-recommends \
        apt-utils \
        ca-certificates \
        cifs-utils \
        curl \
        gnupg \
        gosu \
        iputils-ping \
        jq \
        libatomic1 \
        locales \
        nfs-common \
        procps \
        python3 \
        python3-dev \
        tar \
        tzdata \
        udev \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i 's/^# *\(de_DE.UTF-8\)/\1/' /etc/locale.gen \
    && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen

# Copy scripts early (small layer, changes rarely)
COPY scripts /opt/scripts
COPY userscripts /opt/userscripts

# Install and configure ioBroker (single layer to minimize image size)
RUN mkdir /opt/.docker_config \
    && echo "starting" > /opt/.docker_config/.healthcheck \
    && echo "${VERSION}" > /opt/.docker_config/.thisisdocker \
    && echo "${BUILD}" > /opt/.docker_config/.build \
    && echo "true" > /opt/.docker_config/.first_run \
    && mkdir /opt/scripts/.docker_config \
    && echo "${VERSION}" > /opt/scripts/.docker_config/.thisisdocker \
    && curl -sL https://iobroker.net/install.sh -o install.sh \
    && bash install.sh \
    && rm install.sh \
    && iobroker unsetup -y \
    && echo "true" > /opt/iobroker/.fresh_install \
    && tar -czf /opt/initial_iobroker.tar.gz /opt/iobroker \
    && rm -rf /opt/iobroker && mkdir /opt/iobroker \
    && tar -czf /opt/initial_userscripts.tar.gz /opt/userscripts \
    && if id -u 1000 >/dev/null 2>&1 && [ "$(id -un 1000)" != "iobroker" ]; then userdel -r $(id -un 1000) 2>/dev/null || true; fi \
    && if getent group 1000 >/dev/null 2>&1 && [ "$(getent group 1000 | cut -d: -f1)" != "iobroker" ]; then groupdel $(getent group 1000 | cut -d: -f1) 2>/dev/null || true; fi \
    && chsh -s /bin/bash iobroker \
    && usermod --home /opt/iobroker iobroker \
    && usermod -u 1000 iobroker \
    && groupmod -g 1000 iobroker \
    && chown root:iobroker /usr/sbin/gosu \
    && chown -R iobroker:iobroker /opt/scripts /opt/userscripts \
    && chmod 755 /opt/scripts/*.sh \
    && chmod 755 /opt/userscripts/*.sh \
    && ln -s /opt/scripts/maintenance.sh /bin/maintenance \
    && ln -s /opt/scripts/maintenance.sh /bin/maint \
    && ln -s /opt/scripts/maintenance.sh /bin/m \
    && rm -rf /tmp/* /var/tmp/* /root/.cache/* /root/.npm/*

# Default environment variables
ENV BUILD="${BUILD}" \
    DEBIAN_FRONTEND="teletype" \
    LANG="de_DE.UTF-8" \
    LANGUAGE="de_DE:de" \
    LC_ALL="de_DE.UTF-8" \
    SETGID=1000 \
    SETUID=1000 \
    TZ="Europe/Berlin"

# Default admin ui port
EXPOSE 8081

# Change work dir
WORKDIR /opt/iobroker/

# Healthcheck
HEALTHCHECK --interval=15s --timeout=5s --retries=5 \
    CMD ["/bin/bash", "-c", "/opt/scripts/healthcheck.sh"]

# Volume for persistent data
VOLUME ["/opt/iobroker"]

# Run startup-script
ENTRYPOINT ["/bin/bash", "-c", "/opt/scripts/iobroker_startup.sh"]
