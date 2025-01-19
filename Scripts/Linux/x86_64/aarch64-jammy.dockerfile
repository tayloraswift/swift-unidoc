FROM tayloraswift/swift-cross-aarch64:6.0.3-jammy

# Only bash supports multiline strings
SHELL ["/bin/bash", "-c"]

RUN dpkg --add-architecture arm64

## Arch-qualify the current sources
RUN sed -i "s/deb h/deb [arch=amd64] h/g" /etc/apt/sources.list

## Add AArch64 sources — the `jemalloc` package is part of the `universe` component.
RUN echo $'deb [arch=arm64] http://ports.ubuntu.com jammy main universe\n\
deb [arch=arm64] http://ports.ubuntu.com jammy-security main universe\n\
deb [arch=arm64] http://ports.ubuntu.com jammy-backports main universe\n\
deb [arch=arm64] http://ports.ubuntu.com jammy-updates main universe\n' \
    > /etc/apt/sources.list.d/arm64.list

RUN apt update
RUN apt -y install libjemalloc-dev:arm64 libjemalloc2:arm64
