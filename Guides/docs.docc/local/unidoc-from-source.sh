mkdir -p ~/unidoc/bin
git clone https://github.com/tayloraswift/swift-unidoc
cd swift-unidoc
swift build -c release --product unidoc
mv .build/release/unidoc ~/unidoc/bin/unidoc
