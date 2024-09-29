UNIDOC_MIRROR=https://static.swiftinit.org/unidoc
UNIDOC_VERSION=0.19.4
UNIDOC_PLATFORM=macOS-ARM64

curl -L $UNIDOC_MIRROR/$UNIDOC_VERSION/$UNIDOC_PLATFORM/unidoc.tar.gz \
    -o unidoc.tar.gz
tar -xf unidoc.tar.gz
sudo mv unidoc /usr/local/bin/unidoc
