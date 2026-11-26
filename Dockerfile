FROM debian:13-slim

ARG TARGETARCH
ARG MEGACMD_VERSION=2.7.1-1.1
ARG MEGACMD_SHA256_AMD64=c5eac2e35031701bee220d0d95e9be87cef15d86fd525e0fadb668e11e3162bc
ARG MEGACMD_SHA256_ARM64=ee32a39b0e790f91de63e06ea6d7a19a415bce349c88ff6228909cc463ef9f02

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget ca-certificates gosu \
    && ARCH="${TARGETARCH:-$(dpkg --print-architecture)}" \
    && case "$ARCH" in \
        amd64) MEGACMD_SHA256="$MEGACMD_SHA256_AMD64" ;; \
        arm64) MEGACMD_SHA256="$MEGACMD_SHA256_ARM64" ;; \
        *) echo "unsupported architecture: $ARCH" >&2; exit 1 ;; \
    esac \
    && wget -q "https://mega.nz/linux/repo/Debian_13/${ARCH}/megacmd_${MEGACMD_VERSION}_${ARCH}.deb" \
    && echo "${MEGACMD_SHA256}  megacmd_${MEGACMD_VERSION}_${ARCH}.deb" | sha256sum -c - \
    && apt-get install -y "./megacmd_${MEGACMD_VERSION}_${ARCH}.deb" \

    # Cleanup
    && rm *.deb \
    && apt-get purge -y wget \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

HEALTHCHECK --start-period=30s --interval=30s --timeout=10s CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/entrypoint.sh"]
