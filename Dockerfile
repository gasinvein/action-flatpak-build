FROM fedora:33

RUN dnf install -y \
        flatpak \
        flatpak-builder \
        git \
    && \
    dnf clean all

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
