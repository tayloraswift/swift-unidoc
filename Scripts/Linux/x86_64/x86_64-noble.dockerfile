FROM tayloraswift/swiftcross:6.3-noble

RUN apt update
RUN apt -y install libjemalloc-dev:amd64 libjemalloc2:amd64
