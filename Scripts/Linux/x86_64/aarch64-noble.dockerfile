FROM tayloraswift/swift-cross-aarch64:6.0.2-noble

# Only bash supports multiline strings
SHELL ["/bin/bash", "-c"]

RUN dpkg --add-architecture arm64

## Arch-qualify the current sources (noble uses the deb822 format)
RUN sed -i "s/Types: deb/Types: deb\nArchitectures: amd64/" \
    /etc/apt/sources.list.d/ubuntu.sources

## Add AArch64 sources — the `jemalloc` package is part of the `universe` component.
RUN echo $'Types: deb\n\
Architectures: arm64\n\
URIs: http://ports.ubuntu.com\n\
Suites: noble noble-updates noble-backports\n\
Components: main universe\n\
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg\n\
\n\
Types: deb\n\
Architectures: arm64\n\
URIs: http://ports.ubuntu.com\n\
Suites: noble-security\n\
Components: main universe\n\
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg\n' \
    > /etc/apt/sources.list.d/arm64.sources

RUN apt update
RUN apt -y install libjemalloc-dev:arm64 libjemalloc2:arm64
