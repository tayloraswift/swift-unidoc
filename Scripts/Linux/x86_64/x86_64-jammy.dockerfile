FROM tayloraswift/swift-cross-aarch64:6.1.2-jammy

RUN apt update
RUN apt -y install libjemalloc-dev:amd64 libjemalloc2:amd64
