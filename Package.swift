// swift-tools-version:6.0
import class Foundation.ProcessInfo
import PackageDescription
import CompilerPluginSupport

let package:Package = .init(
    name: "Swift Unidoc",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .visionOS(.v2), .watchOS(.v11)],
    products: [
        .executable(name: "ssgc", targets: ["ssgc"]),
        .executable(name: "unidoc", targets: ["unidoc-tools"]),
        .executable(name: "unidoc-linkerd", targets: ["unidoc-linkerd"]),
        .executable(name: "unidocd", targets: ["unidocd"]),

        .library(name: "guides", targets: ["guides"]),

        .library(name: "Availability", targets: ["Availability"]),
        .library(name: "AvailabilityDomain", targets: ["AvailabilityDomain"]),

        .library(name: "GitHubAPI", targets: ["GitHubAPI"]),
        .library(name: "GitHubClient", targets: ["GitHubClient"]),

        .library(name: "HTTP", targets: ["HTTP"]),
        .library(name: "HTTPClient", targets: ["HTTPClient"]),
        .library(name: "HTTPServer", targets: ["HTTPServer"]),

        .library(name: "InlineArray", targets: ["InlineArray"]),

        .library(name: "InlineDictionary", targets: ["InlineDictionary"]),
        .library(name: "LinkResolution", targets: ["LinkResolution"]),
        .library(name: "LexicalPaths", targets: ["LexicalPaths"]),

        .library(name: "MarkdownABI", targets: ["MarkdownABI"]),
        .library(name: "MarkdownAST", targets: ["MarkdownAST"]),
        .library(name: "MarkdownParsing", targets: ["MarkdownParsing"]),
        .library(name: "MarkdownRendering", targets: ["MarkdownRendering"]),
        .library(name: "MarkdownSemantics", targets: ["MarkdownSemantics"]),

        .library(name: "Media", targets: ["Media"]),

        .library(name: "Multiparts", targets: ["Multiparts"]),

        .library(name: "PieCharts", targets: ["PieCharts"]),
        .library(name: "PackageGraphs", targets: ["PackageGraphs"]),
        .library(name: "PackageMetadata", targets: ["PackageMetadata"]),

        .library(name: "S3", targets: ["S3"]),
        .library(name: "S3Client", targets: ["S3Client"]),

        .library(name: "SemanticVersions", targets: ["SemanticVersions"]),
        .library(name: "Signatures", targets: ["Signatures"]),
        .library(name: "Sitemaps", targets: ["Sitemaps"]),
        .library(name: "SourceDiagnostics", targets: ["SourceDiagnostics"]),
        .library(name: "Sources", targets: ["Sources"]),

        .library(name: "SymbolGraphBuilder", targets: ["SymbolGraphBuilder"]),
        .library(name: "SymbolGraphCompiler", targets: ["SymbolGraphCompiler"]),
        .library(name: "SymbolGraphLinker", targets: ["SymbolGraphLinker"]),
        .library(name: "SymbolGraphParts", targets: ["SymbolGraphParts"]),
        .library(name: "SymbolGraphs", targets: ["SymbolGraphs"]),
        .library(name: "Symbols", targets: ["Symbols"]),

        .library(name: "UnidocAPI", targets: ["UnidocAPI"]),
        .library(name: "UnidocAssets", targets: ["UnidocAssets"]),
        .library(name: "UnidocAssets_System", targets: ["UnidocAssets_System"]),
        .library(name: "UnidocCLI", targets: ["UnidocCLI"]),
        .library(name: "UnidocClient", targets: ["UnidocClient"]),
        .library(name: "UnidocDB", targets: ["UnidocDB"]),
        .library(name: "UnidocLinker", targets: ["UnidocLinker"]),
        .library(name: "UnidocLinkerPlugin", targets: ["UnidocLinkerPlugin"]),
        .library(name: "UnidocQueries", targets: ["UnidocQueries"]),
        .library(name: "UnidocRecords", targets: ["UnidocRecords"]),
        .library(name: "UnidocServer", targets: ["UnidocServer"]),
        .library(name: "UnidocUI", targets: ["UnidocUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tayloraswift/swift-bson", .upToNextMinor(
            from: "1.0.0")),
        .package(url: "https://github.com/tayloraswift/swift-dom", .upToNextMinor(
            from: "1.1.0")),
        .package(url: "https://github.com/tayloraswift/swift-grammar", .upToNextMinor(
            from: "0.5.0")),
        .package(url: "https://github.com/tayloraswift/swift-hash", .upToNextMinor(
            from: "0.7.1")),
        .package(url: "https://github.com/tayloraswift/swift-ip", .upToNextMinor(
            from: "0.3.3")),
        .package(url: "https://github.com/tayloraswift/swift-io", .upToNextMinor(
            from: "0.1.0")),
        .package(url: "https://github.com/tayloraswift/swift-json", .upToNextMinor(
            from: "1.1.2")),
        .package(url: "https://github.com/tayloraswift/swift-mongodb", .upToNextMinor(
            from: "0.29.3")),
        .package(url: "https://github.com/tayloraswift/swift-png", .upToNextMinor(
            from: "4.4.9")),
        .package(url: "https://github.com/tayloraswift/swift-ucf", .upToNextMinor(
            from: "0.2.0")),
        .package(url: "https://github.com/tayloraswift/swift-unixtime", .upToNextMinor(
            from: "0.2.0")),

        // .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(
        //     from: "1.5.0")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "1.5.1")),
        .package(url: "https://github.com/apple/swift-atomics", .upToNextMinor(
            from: "1.2.0")),
        .package(url: "https://github.com/apple/swift-collections", .upToNextMinor(
            from: "1.1.1")),

        .package(url: "https://github.com/apple/swift-nio", from: "2.79.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl", from: "2.27.0"),

        .package(url: "https://github.com/apple/swift-nio-http2", .upToNextMinor(
            from: "1.33.0")),
        .package(url: "https://github.com/apple/swift-markdown", .upToNextMinor(
            from: "0.4.0")),
        .package(url: "https://github.com/apple/swift-syntax",
            from: "600.0.1"),
    ],
    targets: [
        .executableTarget(name: "ssgc",
            dependencies: [
                .target(name: "SymbolGraphBuilder"),
            ]),

        .executableTarget(name: "unidoc-tools",
            dependencies: [
                .target(name: "UnidocCLI"),
                .target(name: "UnidocClient"),
                .target(name: "UnidocServer"),
                .target(name: "UnidocServerInsecure"),
                .target(name: "UnidocLinkerPlugin"),
            ]),

        .executableTarget(name: "unidoc-linkerd",
            dependencies: [
                .target(name: "UnidocCLI"),
                .target(name: "UnidocServer"),
                .target(name: "UnidocServerInsecure"),
                .target(name: "UnidocLinkerPlugin"),
            ]),

        .executableTarget(name: "unidocd",
            dependencies: [
                .target(name: "UnidocClient"),
                .product(name: "System_ArgumentParser", package: "swift-io"),
                .product(name: "UnixCalendar", package: "swift-unixtime"),
            ]),


        .target(name: "_AsyncChannel",
            dependencies: [
                .product(name: "OrderedCollections", package: "swift-collections"),
            ]),

        .target(name: "_GitVersion",
            cSettings: [
                .define("SWIFTPM_GIT_VERSION", to: "\"\(version)\"")
            ]),

        .target(name: "AvailabilityDomain"),

        .target(name: "Availability",
            dependencies: [
                .target(name: "AvailabilityDomain"),
                .target(name: "SemanticVersions"),
            ]),

        .target(name: "Fingerprinting",
            dependencies: [
                .target(name: "HTTP"),
                .product(name: "ISO", package: "swift-unixtime"),
            ]),

        .target(name: "GitHubClient",
            dependencies: [
                .target(name: "GitHubAPI"),
                .target(name: "HTTPClient"),

                .product(name: "Base64", package: "swift-hash"),
            ]),

        .target(name: "GitHubAPI",
            dependencies: [
                .target(name: "SHA1_JSON"),
                .product(name: "UnixTime", package: "swift-unixtime"),
            ]),

        .target(name: "HTTP",
            dependencies: [
                .target(name: "Media"),
                .product(name: "ISO", package: "swift-unixtime"),
                .product(name: "MD5", package: "swift-hash"),
                .product(name: "NIOCore", package: "swift-nio"),
            ]),

        .target(name: "HTTPClient",
            dependencies: [
                .target(name: "HTTP"),
                .target(name: "Media"),
                .product(name: "MD5", package: "swift-hash"),
                .product(name: "HTML", package: "swift-dom"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOHTTP2", package: "swift-nio-http2"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),

        .target(name: "HTTPServer",
            dependencies: [
                .target(name: "_AsyncChannel"),
                .target(name: "HTTP"),

                .product(name: "Firewalls", package: "swift-ip"),
                .product(name: "IP", package: "swift-ip"),
                .product(name: "IP_NIOCore", package: "swift-ip"),
                .product(name: "HTML", package: "swift-dom"),
                .product(name: "Atomics", package: "swift-atomics"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOHTTP2", package: "swift-nio-http2"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
                .product(name: "URI", package: "swift-ucf"),
            ]),

        .target(name: "InlineArray"),

        .target(name: "InlineDictionary"),

        .target(name: "LexicalPaths"),

        .target(name: "LinkResolution",
            dependencies: [
                .target(name: "InlineArray"),
                .target(name: "LexicalPaths"),
                .target(name: "SourceDiagnostics"),
                .target(name: "Symbols"),
                //  This dependency is present for (questionable?) performance reasons.
                .target(name: "Unidoc"),
                .product(name: "UCF", package: "swift-ucf"),
            ]),

        .target(name: "MarkdownABI"),

        .target(name: "MarkdownAST",
            dependencies: [
                .target(name: "MarkdownABI"),
                .target(name: "Sources"),
                .target(name: "Symbols"),
            ]),

        .target(name: "MarkdownDisplay",
            dependencies: [
                .target(name: "MarkdownABI"),
            ]),

        .target(name: "MarkdownRendering",
            dependencies: [
                .target(name: "MarkdownABI"),
                .product(name: "HTML", package: "swift-dom"),
                .product(name: "URI", package: "swift-ucf"),
            ]),

        .target(name: "MarkdownParsing",
            dependencies: [
                .target(name: "MarkdownAST"),
                .target(name: "SourceDiagnostics"),
                //  TODO: this links Foundation. Need to find a replacement.
                .product(name: "Markdown", package: "swift-markdown"),
            ]),

        .target(name: "MarkdownPluginSwift",
            dependencies: [
                .target(name: "MarkdownABI"),
                .target(name: "Signatures"),
                .target(name: "Snippets"),
                .target(name: "Sources"),
                .target(name: "Symbols"),

                .product(name: "SwiftIDEUtils", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ]),

        .target(name: "MarkdownSemantics",
            dependencies: [
                .target(name: "MarkdownAST"),
                .target(name: "MarkdownDisplay"),
                .target(name: "Snippets"),
                .target(name: "SourceDiagnostics"),
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "UCF", package: "swift-ucf"),
            ]),

        .target(name: "Media"),

        .target(name: "_MongoDB",
            dependencies: [
                .product(name: "MongoDB", package: "swift-mongodb"),
            ]),

        .target(name: "Multiparts",
            dependencies: [
                .target(name: "Media"),
                .product(name: "Grammar", package: "swift-grammar"),
            ]),

        .target(name: "PieCharts",
            dependencies: [
                .product(name: "HTML", package: "swift-dom"),
            ]),

        .target(name: "PackageGraphs",
            dependencies: [
                .target(name: "SymbolGraphs"),
                .target(name: "TopologicalSorting"),
            ]),

        .target(name: "PackageMetadata",
            dependencies: [
                .target(name: "SHA1_JSON"),
                .target(name: "PackageGraphs"),
                .product(name: "OrderedCollections", package: "swift-collections"),
            ]),

        .target(name: "S3",
            dependencies: [
            ]),

        .target(name: "S3Client",
            dependencies: [
                .target(name: "HTTPClient"),
                .target(name: "Media"),
                .target(name: "S3"),
                .product(name: "UnixCalendar", package: "swift-unixtime"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "SHA2", package: "swift-hash"),
            ]),

        .target(name: "SemanticVersions"),

        .target(name: "Signatures",
            dependencies: [
                .target(name: "Availability"),
                .target(name: "MarkdownABI")
            ]),

        .target(name: "SHA1_JSON",
            dependencies: [
                .product(name: "JSON", package: "swift-json"),
                .product(name: "SHA1", package: "swift-hash"),
            ]),

        .target(name: "Sitemaps",
            dependencies: [
                .product(name: "DOM", package: "swift-dom"),
            ]),

        .target(name: "Snippets",
            dependencies: [
                .target(name: "MarkdownABI"),
            ]),

        .target(name: "SourceDiagnostics",
            dependencies: [
                .target(name: "Symbols"),
                .target(name: "Sources"),
            ]),

        .target(name: "Sources"),

        .target(name: "Symbols",
            dependencies: [
                .target(name: "Sources"),
                .product(name: "FNV1", package: "swift-ucf"),
            ]),

        .target(name: "SymbolGraphBuilder",
            dependencies: [
                .target(name: "MarkdownPluginSwift"),
                .target(name: "MarkdownPluginSwift_IndexStoreDB"),
                .target(name: "PackageMetadata"),
                .target(name: "SymbolGraphCompiler"),
                .target(name: "SymbolGraphLinker"),
                .product(name: "SystemIO", package: "swift-io"),
                .product(name: "System_ArgumentParser", package: "swift-io"),
            ]),

        .target(name: "SymbolGraphCompiler",
            dependencies: [
                .target(name: "LinkResolution"),
                .target(name: "SymbolGraphParts"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),

        .target(name: "SymbolGraphLinker",
            dependencies: [
                .target(name: "InlineArray"),
                .target(name: "InlineDictionary"),
                .target(name: "MarkdownParsing"),
                .target(name: "MarkdownRendering"),
                .target(name: "MarkdownSemantics"),
                .target(name: "SemanticVersions"),
                .target(name: "Snippets"),
                .target(name: "SymbolGraphCompiler"),
                .target(name: "SymbolGraphs"),
                .target(name: "Symbols"),
                .target(name: "SourceDiagnostics"),
                .product(name: "SHA1", package: "swift-hash"),
                .product(name: "URI", package: "swift-ucf"),
            ]),

        .target(name: "SymbolGraphParts",
            dependencies: [
                .target(name: "LexicalPaths"),
                .target(name: "LinkResolution"),
                //  This is the point where the symbol graph compiler becomes infected with a
                //  (non-macro) SwiftSyntax dependency.
                //
                //  This also means that the static symbol graph linker can freely use any
                //  of the SwiftSyntax-powered plugins, since we have already paid for the
                //  dependency.
                .target(name: "MarkdownPluginSwift"),
                .target(name: "Signatures"),
                .target(name: "Symbols"),
                .product(name: "JSON", package: "swift-json"),
            ]),

        .target(name: "SymbolGraphs",
            dependencies: [
                .target(name: "LexicalPaths"),
                .target(name: "SemanticVersions"),
                .target(name: "Signatures"),
                .target(name: "Symbols"),

                .product(name: "BSON", package: "swift-bson"),
                .product(name: "SHA1", package: "swift-hash"),
            ],
            exclude:
            [
                "README.md",
            ]),

        .target(name: "SymbolGraphTesting",
            dependencies: [
                .target(name: "SymbolGraphs"),
                .product(name: "SystemIO", package: "swift-io"),
            ]),

        .target(name: "TopologicalSorting"),

        .target(name: "Testing_",
            dependencies: [
                .product(name: "Atomics", package: "swift-atomics"),
            ]),

        .target(name: "Unidoc"),

        .target(name: "UnidocAPI",
            dependencies: [
                .target(name: "SemanticVersions"),
                .target(name: "SHA1_JSON"),
                .target(name: "Symbols"),
                .target(name: "Unidoc"),
                .product(name: "URI", package: "swift-ucf"),
            ]),

        .target(name: "UnidocAssets",
            dependencies: [
                .target(name: "SemanticVersions"),
                .target(name: "Unidoc"),
            ]),

        .target(name: "UnidocAssets_System",
            dependencies: [
                .target(name: "Media"),
                .target(name: "UnidocAssets"),
                .product(name: "SystemIO", package: "swift-io"),
            ]),

        .target(name: "UnidocCLI",
            dependencies: [
                .target(name: "_GitVersion"),
                .target(name: "UnidocServer"),
                .product(name: "System_ArgumentParser", package: "swift-io"),
            ]),

        .target(name: "UnidocClient",
            dependencies: [
                .target(name: "HTTPClient"),
                .target(name: "SymbolGraphBuilder"),
                .target(name: "UnidocRecords_LZ77"),
                .target(name: "UnidocRecords"),
            ]),

        .target(name: "UnidocDB",
            dependencies: [
                .target(name: "_MongoDB"),
                .target(name: "UnidocRecords_LZ77"),
                .target(name: "UnidocLinking"),
                .target(name: "UnidocRecords"),
                .product(name: "IP", package: "swift-ip"),
                .product(name: "UnixCalendar", package: "swift-unixtime"),
            ]),

        .target(name: "UnidocRecords_LZ77",
            dependencies: [
                .target(name: "UnidocRecords"),
                .product(name: "LZ77", package: "swift-png"),
            ]),

        .target(name: "UnidocLinker",
            dependencies: [
                .target(name: "MarkdownRendering"),
                .target(name: "SourceDiagnostics"),
                .target(name: "UnidocLinking"),
            ]),

        .target(name: "UnidocLinkerPlugin",
            dependencies: [
                .target(name: "UnidocLinker"),
                .target(name: "UnidocServer"),
            ]),

        .target(name: "UnidocLinking",
            dependencies: [
                .target(name: "UnidocRecords"),
            ]),

        .target(name: "UnidocQueries",
            dependencies: [
                .target(name: "UnidocDB"),
                .target(name: "UnidocRecords"),
            ]),

        .target(name: "UnidocRecords",
            dependencies: [
                .target(name: "GitHubAPI"),
                .target(name: "SymbolGraphs"),
                .target(name: "UnidocAPI"),
                .product(name: "FNV1", package: "swift-ucf"),
                .product(name: "MD5", package: "swift-hash"),
            ]),

        .target(name: "UnidocRender",
            dependencies: [
                .target(name: "HTTP"),
                .target(name: "MarkdownDisplay"),
                .target(name: "MarkdownRendering"),
                .target(name: "Media"),
                .target(name: "UnidocAssets"),
                .target(name: "UnidocRecords"),
                .product(name: "UnixCalendar", package: "swift-unixtime"),
                .product(name: "HTML", package: "swift-dom"),
            ]),

        .target(name: "UnidocServer",
            dependencies: [
                .target(name: "GitHubClient"),
                .target(name: "HTTPClient"),
                .target(name: "HTTPServer"),
                .target(name: "Media"),
                .target(name: "Multiparts"),
                .target(name: "S3Client"),
                .target(name: "Sitemaps"),
                .target(name: "UnidocAssets"),
                .target(name: "UnidocAssets_System"),
                .target(name: "UnidocAPI"),
                .target(name: "UnidocDB"),
                .target(name: "Fingerprinting"),
                .target(name: "UnidocQueries"),
                .target(name: "UnidocRender"),
                .target(name: "UnidocUI"),
            ]),

        .target(name: "UnidocServerInsecure",
            dependencies: [
                .target(name: "UnidocServer"),
            ]),

        .target(name: "UnidocTesting",
            dependencies: [
                .target(name: "UnidocDB"),
                .target(name: "UnidocLinker"),
                .product(name: "MongoTesting", package: "swift-mongodb"),
            ]),

        .target(name: "UnidocUI",
            dependencies: [
                .target(name: "GitHubAPI"),
                .target(name: "PieCharts"),
                .target(name: "UnidocRender"),
                .target(name: "UnidocAPI"),
                .target(name: "UnidocQueries"),
                .product(name: "URI", package: "swift-ucf"),
                .product(name: "UnixTime", package: "swift-unixtime"),
            ]),


        .testTarget(name: "FingerprintingTests",
            dependencies: [
                .target(name: "Fingerprinting"),
            ]),

        .testTarget(name: "MarkdownParsingTests",
            dependencies: [
                .target(name: "MarkdownParsing"),
                .target(name: "MarkdownSemantics"),
            ]),

        .testTarget(name: "MarkdownPluginSwiftTests",
            dependencies: [
                .target(name: "MarkdownPluginSwift"),
                .target(name: "MarkdownRendering"),
            ]),

        .testTarget(name: "MarkdownRenderingTests",
            dependencies: [
                .target(name: "MarkdownRendering"),
            ]),

        .testTarget(name: "PackageMetadataTests",
            dependencies: [
                .target(name: "PackageMetadata"),
                .product(name: "SystemIO", package: "swift-io"),
            ]),

        .testTarget(name: "S3Tests",
            dependencies: [
                .target(name: "S3Client"),
            ]),

        .testTarget(name: "SemanticVersionTests",
            dependencies: [
                .target(name: "SemanticVersions"),
            ]),

        .testTarget(name: "SymbolGraphValidationTests",
            dependencies: [
                .target(name: "SymbolGraphTesting"),
                .product(name: "SystemIO", package: "swift-io"),
            ]),

        .executableTarget(name: "SymbolGraphBuilderTests",
            dependencies: [
                .target(name: "SymbolGraphBuilder"),
                .target(name: "Testing_"),
            ]),

        .executableTarget(name: "SymbolGraphCompilerTests",
            dependencies: [
                .target(name: "SymbolGraphBuilder"),
                .target(name: "Testing_"),
            ]),

        .testTarget(name: "SymbolGraphLinkerTests",
            dependencies: [
                .target(name: "MarkdownRendering"),
                .target(name: "SymbolGraphLinker"),
            ]),

        .testTarget(name: "SymbolGraphPartTests",
            dependencies: [
                .target(name: "SymbolGraphParts"),
                .product(name: "SystemIO", package: "swift-io"),
            ]),

        .testTarget(name: "SymbolGraphTests",
            dependencies: [
                .target(name: "SymbolGraphs"),
            ]),

        .testTarget(name: "SymbolTests",
            dependencies: [
                .target(name: "Symbols"),
            ]),

        .testTarget(name: "TopologicalSortingTests",
            dependencies: [
                .target(name: "TopologicalSorting"),
            ]),

        .testTarget(name: "UnidocDBTests",
            dependencies: [
                .target(name: "UnidocTesting"),
                .target(name: "GitHubClient"),
                .target(name: "SymbolGraphBuilder"),
                .target(name: "SymbolGraphTesting"),
            ]),

        .testTarget(name: "UnidocQueryTests",
            dependencies: [
                .target(name: "UnidocQueries"),
                .target(name: "UnidocTesting"),
                .target(name: "SymbolGraphTesting"),
            ]),

        .testTarget(name: "UnidocRecordsTests",
            dependencies: [
                .target(name: "UnidocRecords"),
            ]),

        .target(name: "guides", path: "Guides"),
    ])

switch ProcessInfo.processInfo.environment["UNIDOC_ENABLE_INDEXSTORE"]?.lowercased()
{
case "1"?, "true"?:
    package.dependencies.append(.package(url: "https://github.com/swiftlang/indexstore-db",
        branch: "main"))

    package.targets.append(.target(name: "MarkdownPluginSwift_IndexStoreDB",
        dependencies: [
            .target(name: "MarkdownPluginSwift"),
            .product(name: "IndexStoreDB", package: "indexstore-db"),
        ]))

default:
    package.targets.append(.target(name: "MarkdownPluginSwift_IndexStoreDB",
        dependencies: [
            .target(name: "MarkdownPluginSwift"),
        ]))
}

for target:PackageDescription.Target in package.targets
{
    if  target.name == "_AsyncChannel"
    {
        continue
    }

    {
        var settings:[PackageDescription.SwiftSetting] = $0 ?? []

        settings.append(.enableUpcomingFeature("ExistentialAny"))
        settings.append(.enableExperimentalFeature("StrictConcurrency"))

        settings.append(.define("DEBUG", .when(configuration: .debug)))

        $0 = settings
    } (&target.swiftSettings)
}

var version:String
{
    if  let git:GitInformation = Context.gitInformation
    {
        let base:String = git.currentTag ?? git.currentCommit
        return git.hasUncommittedChanges ? "\(base) (modified)" : base
    }
    else
    {
        return "(untracked)"
    }
}
