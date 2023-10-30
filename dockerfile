# This dockerfile creates the base image we use to distribute the Unidoc compiler.
# It includes a superset of the system dependencies the swiftpackageindex.com builder
# image supports, so we can compile any package that swiftpackageindex.com can compile.
FROM swift:5.9.1

RUN apt-get update && apt-get install -y \
    sqlite3 libsqlite3-dev \
    libcurl4-openssl-dev  \
    libgtk-3-dev clang \
    libjemalloc-dev

COPY .build/release/UnidocBuild /bin/unidoc-build
RUN chmod +x /bin/unidoc-build
CMD swift --version
