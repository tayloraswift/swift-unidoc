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
            "2.48.0")
    }
}
