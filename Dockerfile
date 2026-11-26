
FROM debian:13-slim

RUN apt-get update \
    && apt-get upgrade -y \

    # Dependencies
    && apt-get install -y --no-install-recommends wget ca-certificates gosu \
    
    # Install MegaCMD
    && wget https://mega.nz/linux/repo/Debian_13/amd64/megacmd-Debian_13_amd64.deb \
    && apt-get install -y "$PWD/megacmd-Debian_13_amd64.deb" \

    # Cleanup
    && rm *.deb \
    && apt-get purge -y wget \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
