UNIDOC_MIRROR=https://static.swiftinit.org/unidoc
UNIDOC_VERSION=0.19.0
UNIDOC_PLATFORM=macOS-ARM64

mkdir -p ~/unidoc/bin
curl -L $UNIDOC_MIRROR/$UNIDOC_VERSION/$UNIDOC_PLATFORM/unidoc.gz \
    -o ~/unidoc/bin/unidoc.gz
gzip -fdk ~/unidoc/bin/unidoc.gz
chmod +x ~/unidoc/bin/unidoc
