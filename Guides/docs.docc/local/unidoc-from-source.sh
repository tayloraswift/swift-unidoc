mkdir -p ~/unidoc/bin
git clone https://github.com/tayloraswift/swift-unidoc
cd swift-unidoc
swift build -c release --product unidoc-tools
mv .build/release/unidoc-tools ~/unidoc/bin/unidoc
