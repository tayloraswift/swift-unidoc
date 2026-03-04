FROM tayloraswift/swift-cross-aarch64:6.2.4-jammy

RUN apt update
RUN apt -y install libjemalloc-dev:amd64 libjemalloc2:amd64
