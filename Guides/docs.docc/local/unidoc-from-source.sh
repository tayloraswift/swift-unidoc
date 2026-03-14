git clone https://github.com/rarestype/unidoc
cd swift-unidoc
swift build -c release --product unidoc
mv .build/release/unidoc /usr/local/bin/unidoc
