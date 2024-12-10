FROM tayloraswift/swift-cross-aarch64:6.0.2-noble

RUN apt update
RUN apt -y install libjemalloc-dev:amd64 libjemalloc2:amd64
