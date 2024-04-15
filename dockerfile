# Most Unidoc users do *not* need to build this image!

# This dockerfile creates the base image we use to distribute the Unidoc compiler.
# It includes a superset of the system dependencies the swiftpackageindex.com builder
# image supports, so we can compile any package that swiftpackageindex.com can compile.
FROM swift:5.10

RUN apt update && apt install -y \
    sqlite3 libsqlite3-dev \
    libcurl4-openssl-dev  \
    libgtk-3-dev clang \
    libjemalloc-dev \
    libcap2-bin

COPY .build/x86_64-unknown-linux-gnu/release/SwiftinitServer /bin/swiftinit
COPY .build/x86_64-unknown-linux-gnu/release/unidoc-build /bin/unidoc-build
COPY .build/x86_64-unknown-linux-gnu/release/ssgc /bin/ssgc

RUN chmod +x /bin/swiftinit
RUN chmod +x /bin/unidoc-build
RUN chmod +x /bin/ssgc

CMD swift --version
