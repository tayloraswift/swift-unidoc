import SymbolGraphBuilder

@main
enum Main
{
    public static
    func main() async throws
    {
        let builder:Massbuilder = try await .init()

        try await builder.buildStandardLibrary()

        try await builder.buildLiterature()

        try await builder.build("swift-atomics",
            repository: "https://github.com/apple/swift-atomics.git",
            versions:
            "1.0.2",
            "1.1.0")

        try await builder.build("swift-collections",
            repository: "https://github.com/apple/swift-collections.git",
            versions:
            "1.0.2")

        try await builder.build("swift-numerics",
            repository: "https://github.com/apple/swift-numerics.git",
            versions:
            "1.0.2")

        try await builder.build("swift-algorithms",
            repository: "https://github.com/apple/swift-algorithms.git",
            versions:
            "1.0.0")

        try await builder.build("swift-argument-parser",
            repository: "https://github.com/apple/swift-argument-parser.git",
            versions:
            "1.1.3")

        try await builder.build("swift-markdown",
            repository: "https://github.com/apple/swift-markdown.git",
            versions:
            "0.2.0")

        try await builder.build("swift-syntax",
            repository: "https://github.com/apple/swift-syntax.git",
            versions:
            "508.0.1",
            "509.0.0")

        try await builder.build("swift-system",
            repository: "https://github.com/apple/swift-system.git",
            versions:
            "1.1.0",
            "1.1.1",
            "1.2.0",
            "1.2.1")

        try await builder.build("swift-nio",
            repository: "https://github.com/apple/swift-nio.git",
            versions:
            "2.38.0",
            "2.39.0",
            "2.40.0",
            "2.41.0",
            "2.42.0",
            "2.43.0",
            "2.44.0",
            "2.45.0",
            "2.46.0",
            "2.47.0",
            "2.48.0",
            "2.49.0",
            "2.50.0",
            "2.51.0",
            "2.52.0",
            "2.53.0",
            "2.54.0",
            "2.55.0",
            "2.56.0",
            "2.57.0",
            "2.58.0")

        try await builder.build("swift-nio-ssl",
            repository: "https://github.com/apple/swift-nio-ssl.git",
            versions:
            "2.20.2",
            "2.21.0",
            "2.22.0",
            "2.23.0",
            "2.24.0",
            "2.25.0")

        try await builder.build("swift-log",
            repository: "https://github.com/apple/swift-log.git",
            versions:
            "1.4.2",
            "1.4.3",
            "1.4.4",
            "1.5.0",
            "1.5.1",
            "1.5.2",
            "1.5.3")

        try await builder.build("swift-metrics",
            repository: "https://github.com/apple/swift-metrics.git",
            versions:
            "2.3.1",
            "2.3.2",
            "2.3.3",
            "2.3.4",
            "2.4.0",
            "2.4.1")

        try await builder.build("swift-certificates",
            repository: "https://github.com/apple/swift-certificates.git",
            versions:
            "0.6.0")

        try await builder.build("swift-asn1",
            repository: "https://github.com/apple/swift-asn1.git",
            versions:
            "0.8.0",
            "0.9.1",
            "0.10.0")

        try await builder.build("swift-crypto",
            repository: "https://github.com/apple/swift-crypto.git",
            versions:
            "2.6.0")

        try await builder.build("swift-nio-http2",
            repository: "https://github.com/apple/swift-nio-http2.git",
            versions:
            "1.27.0")

        try await builder.build("swift-hash",
            repository: "https://github.com/tayloraswift/swift-hash.git",
            versions:
            "v0.2.3")

        try await builder.build("swift-dom",
            repository: "https://github.com/tayloraswift/swift-dom.git",
            versions:
            "v0.5.0")

        try await builder.build("swift-grammar",
            repository: "https://github.com/tayloraswift/swift-grammar.git",
            versions:
            "v0.1.4",
            "v0.1.5",
            "v0.2.0")

        try await builder.build("swift-json",
            repository: "https://github.com/tayloraswift/swift-json.git",
            versions:
            "v0.2.2",
            "v0.3.0")

        try await builder.build("bson",
            repository: "https://github.com/orlandos-nl/bson.git",
            versions:
            "8.0.1",
            "8.0.10")

        try await builder.build("dnsclient",
            repository: "https://github.com/orlandos-nl/dnsclient.git",
            versions:
            "2.4.1")

        try await builder.build("mongokitten",
            repository: "https://github.com/orlandos-nl/mongokitten.git",
            versions:
            "7.0.1",
            "7.1.0",
            "7.2.0",
            "7.2.1",
            "7.2.2")
            // "7.7.1"
    }
}
