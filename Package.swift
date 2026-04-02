// swift-tools-version:6.2
import class Foundation.ProcessInfo
import PackageDescription
import CompilerPluginSupport

let package: Package = .init(
    name: "unidoc",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .visionOS(.v2), .watchOS(.v11)],
    products: [
        .executable(name: "ssgc", targets: ["ssgc"]),
        .executable(name: "unidoc", targets: ["unidoc-tools"]),
        .executable(name: "unidoc-linkerd", targets: ["unidoc-linkerd"]),
        .executable(name: "unidocd", targets: ["unidocd"]),

        .library(name: "guides", targets: ["guides"]),

        .library(name: "Availability", targets: ["Availability"]),
        .library(name: "AvailabilityDomain", targets: ["AvailabilityDomain"]),

        .library(name: "InlineArray", targets: ["InlineArray"]),

        .library(name: "InlineDictionary", targets: ["InlineDictionary"]),
        .library(name: "LinkResolution", targets: ["LinkResolution"]),
        .library(name: "LexicalPaths", targets: ["LexicalPaths"]),

        .library(name: "MarkdownABI", targets: ["MarkdownABI"]),
        .library(name: "MarkdownAST", targets: ["MarkdownAST"]),
        .library(name: "MarkdownParsing", targets: ["MarkdownParsing"]),
        .library(name: "MarkdownRendering", targets: ["MarkdownRendering"]),
        .library(name: "MarkdownSemantics", targets: ["MarkdownSemantics"]),

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
        .package(url: "https://github.com/ordo-one/dollup", from: "1.0.1"),

        .package(url: "https://github.com/rarestype/gram", from: "1.0.0"),
        .package(url: "https://github.com/rarestype/h", from: "1.0.1"),
        .package(url: "https://github.com/rarestype/swift-bson", from: "2.0.2"),
        .package(url: "https://github.com/rarestype/swift-dom", from: "1.2.3"),
        .package(url: "https://github.com/rarestype/swift-github", from: "1.0.0"),
        .package(url: "https://github.com/rarestype/swift-ip", from: "0.3.6"),
        .package(url: "https://github.com/rarestype/swift-io", from: "1.2.0"),
        .package(url: "https://github.com/rarestype/swift-json", from: "2.3.2"),
        .package(url: "https://github.com/rarestype/swift-mongodb", from: "1.0.0"),
        .package(url: "https://github.com/rarestype/servit", from: "1.1.0"),
        .package(url: "https://github.com/rarestype/u", from: "1.1.0"),
        .package(url: "https://github.com/rarestype/ucf", from: "0.2.1"),

        .package(url: "https://github.com/tayloraswift/swift-png", from: "4.5.1"),

        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.7.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-nio", from: "2.96.0"),
        .package(url: "https://github.com/apple/swift-markdown", from: "0.7.3"),
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "603.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "ssgc",
            dependencies: [
                .target(name: "SymbolGraphBuilder"),
            ]
        ),

        .executableTarget(
            name: "unidoc-tools",
            dependencies: [
                .target(name: "UnidocCLI"),
                .target(name: "UnidocClient"),
                .target(name: "UnidocServer"),
                .target(name: "UnidocServerInsecure"),
                .target(name: "UnidocLinkerPlugin"),
            ]
        ),

        .executableTarget(
            name: "unidoc-linkerd",
            dependencies: [
                .target(name: "UnidocCLI"),
                .target(name: "UnidocServer"),
                .target(name: "UnidocServerInsecure"),
                .target(name: "UnidocLinkerPlugin"),
            ]
        ),

        .executableTarget(
            name: "unidocd",
            dependencies: [
                .target(name: "UnidocClient"),
                .product(name: "System_ArgumentParser", package: "swift-io"),
                .product(name: "UnixCalendar", package: "u"),
            ]
        ),

        .target(
            name: "_GitVersion",
            cSettings: [
                .define("SWIFTPM_GIT_VERSION", to: "\"\(version)\"")
            ]
        ),

        .target(name: "AvailabilityDomain"),

        .target(
            name: "Availability",
            dependencies: [
                .target(name: "AvailabilityDomain"),
                .target(name: "SemanticVersions"),
            ]
        ),

        .target(
            name: "Fingerprinting",
            dependencies: [
                .product(name: "HTTP", package: "servit"),
                .product(name: "ISO", package: "u"),
            ]
        ),

        .target(name: "InlineArray"),

        .target(name: "InlineDictionary"),

        .target(name: "LexicalPaths"),

        .target(
            name: "LinkResolution",
            dependencies: [
                .target(name: "InlineArray"),
                .target(name: "LexicalPaths"),
                .target(name: "SourceDiagnostics"),
                .target(name: "Symbols"),
                //  This dependency is present for (questionable?) performance reasons.
                .target(name: "Unidoc"),
                .product(name: "UCF", package: "ucf"),
            ]
        ),

        .target(name: "MarkdownABI"),

        .target(
            name: "MarkdownAST",
            dependencies: [
                .target(name: "MarkdownABI"),
                .target(name: "Sources"),
                .target(name: "Symbols"),
            ]
        ),

        .target(
            name: "MarkdownDisplay",
            dependencies: [
                .target(name: "MarkdownABI"),
            ]
        ),

        .target(
            name: "MarkdownRendering",
            dependencies: [
                .target(name: "MarkdownABI"),
                .product(name: "HTML", package: "swift-dom"),
                .product(name: "URI", package: "ucf"),
            ]
        ),

        .target(
            name: "MarkdownParsing",
            dependencies: [
                .target(name: "MarkdownAST"),
                .target(name: "SourceDiagnostics"),
                //  TODO: this links Foundation. Need to find a replacement.
                .product(name: "Markdown", package: "swift-markdown"),
            ]
        ),

        .target(
            name: "MarkdownPluginSwift",
            dependencies: [
                .target(name: "MarkdownABI"),
                .target(name: "Signatures"),
                .target(name: "Snippets"),
                .target(name: "Sources"),
                .target(name: "Symbols"),

                .product(name: "SwiftIDEUtils", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ]
        ),

        .target(
            name: "MarkdownSemantics",
            dependencies: [
                .target(name: "MarkdownAST"),
                .target(name: "MarkdownDisplay"),
                .target(name: "Snippets"),
                .target(name: "SourceDiagnostics"),
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "UCF", package: "ucf"),
            ]
        ),

        .target(
            name: "_MongoDB",
            dependencies: [
                .product(name: "MongoDB", package: "swift-mongodb"),
            ]
        ),

        .target(
            name: "PieCharts",
            dependencies: [
                .product(name: "HTML", package: "swift-dom"),
            ]
        ),

        .target(
            name: "PackageGraphs",
            dependencies: [
                .target(name: "SymbolGraphs"),
                .target(name: "TopologicalSorting"),
            ]
        ),

        .target(
            name: "PackageMetadata",
            dependencies: [
                .target(name: "PackageGraphs"),
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "SHA1_JSON", package: "swift-github"),
            ]
        ),

        .target(
            name: "S3",
            dependencies: [
            ]
        ),

        .target(
            name: "S3Client",
            dependencies: [
                .target(name: "S3"),
                .product(name: "HTTPClient", package: "servit"),
                .product(name: "Media", package: "servit"),
                .product(name: "UnixCalendar", package: "u"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "SHA2", package: "h"),
            ]
        ),

        .target(name: "SemanticVersions"),

        .target(
            name: "Signatures",
            dependencies: [
                .target(name: "Availability"),
                .target(name: "MarkdownABI")
            ]
        ),

        .target(
            name: "Sitemaps",
            dependencies: [
                .product(name: "DOM", package: "swift-dom"),
            ]
        ),

        .target(
            name: "Snippets",
            dependencies: [
                .target(name: "MarkdownABI"),
            ]
        ),

        .target(
            name: "SourceDiagnostics",
            dependencies: [
                .target(name: "Symbols"),
                .target(name: "Sources"),
            ]
        ),

        .target(name: "Sources"),

        .target(
            name: "Symbols",
            dependencies: [
                .target(name: "Sources"),
                .product(name: "FNV1", package: "ucf"),
            ]
        ),

        .target(
            name: "SymbolGraphBuilder",
            dependencies: [
                .target(name: "MarkdownPluginSwift"),
                .target(name: "MarkdownPluginSwift_IndexStoreDB"),
                .target(name: "PackageMetadata"),
                .target(name: "SymbolGraphCompiler"),
                .target(name: "SymbolGraphLinker"),
                .product(name: "SystemIO", package: "swift-io"),
                .product(name: "System_ArgumentParser", package: "swift-io"),
            ]
        ),

        .target(
            name: "SymbolGraphCompiler",
            dependencies: [
                .target(name: "LinkResolution"),
                .target(name: "SymbolGraphParts"),
                .product(name: "TraceableErrors", package: "gram"),
            ]
        ),

        .target(
            name: "SymbolGraphLinker",
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
                .product(name: "SHA1", package: "h"),
                .product(name: "URI", package: "ucf"),
            ]
        ),

        .target(
            name: "SymbolGraphParts",
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
            ]
        ),

        .target(
            name: "SymbolGraphs",
            dependencies: [
                .target(name: "LexicalPaths"),
                .target(name: "SemanticVersions"),
                .target(name: "Signatures"),
                .target(name: "Symbols"),

                .product(name: "BSON", package: "swift-bson"),
                .product(name: "SHA1", package: "h"),
            ],
            exclude: [
                "README.md",
            ]
        ),

        .target(
            name: "SymbolGraphTesting",
            dependencies: [
                .target(name: "SymbolGraphs"),
                .product(name: "SystemIO", package: "swift-io"),
            ]
        ),

        .target(name: "TopologicalSorting"),

        .target(name: "Testing_"),

        .target(name: "Unidoc"),

        .target(
            name: "UnidocAPI",
            dependencies: [
                .target(name: "SemanticVersions"),
                .target(name: "Symbols"),
                .target(name: "Unidoc"),
                .product(name: "SHA1_JSON", package: "swift-github"),
                .product(name: "URI", package: "ucf"),
            ]
        ),

        .target(
            name: "UnidocAssets",
            dependencies: [
                .target(name: "SemanticVersions"),
                .target(name: "Unidoc"),
            ]
        ),

        .target(
            name: "UnidocAssets_System",
            dependencies: [
                .target(name: "UnidocAssets"),
                .product(name: "Media", package: "servit"),
                .product(name: "SystemIO", package: "swift-io"),
            ]
        ),

        .target(
            name: "UnidocCLI",
            dependencies: [
                .target(name: "_GitVersion"),
                .target(name: "UnidocServer"),
                .product(name: "System_ArgumentParser", package: "swift-io"),
            ]
        ),

        .target(
            name: "UnidocClient",
            dependencies: [
                .product(name: "HTTPClient", package: "servit"),
                .target(name: "SymbolGraphBuilder"),
                .target(name: "UnidocRecords_LZ77"),
                .target(name: "UnidocRecords"),
            ]
        ),

        .target(
            name: "UnidocDB",
            dependencies: [
                .target(name: "_MongoDB"),
                .target(name: "UnidocRecords_LZ77"),
                .target(name: "UnidocLinking"),
                .target(name: "UnidocRecords"),
                .product(name: "IP", package: "swift-ip"),
                .product(name: "UnixCalendar", package: "u"),
            ]
        ),

        .target(
            name: "UnidocRecords_LZ77",
            dependencies: [
                .target(name: "UnidocRecords"),
                .product(name: "LZ77", package: "swift-png"),
            ]
        ),

        .target(
            name: "UnidocLinker",
            dependencies: [
                .target(name: "MarkdownRendering"),
                .target(name: "SourceDiagnostics"),
                .target(name: "UnidocLinking"),
            ]
        ),

        .target(
            name: "UnidocLinkerPlugin",
            dependencies: [
                .target(name: "UnidocLinker"),
                .target(name: "UnidocServer"),
            ]
        ),

        .target(
            name: "UnidocLinking",
            dependencies: [
                .target(name: "UnidocRecords"),
            ]
        ),

        .target(
            name: "UnidocQueries",
            dependencies: [
                .target(name: "UnidocDB"),
                .target(name: "UnidocRecords"),
            ]
        ),

        .target(
            name: "UnidocRecords",
            dependencies: [
                .target(name: "SymbolGraphs"),
                .target(name: "UnidocAPI"),
                .product(name: "GitHubAPI", package: "swift-github"),
                .product(name: "FNV1", package: "ucf"),
                .product(name: "MD5", package: "h"),
            ]
        ),

        .target(
            name: "UnidocRender",
            dependencies: [
                .target(name: "MarkdownDisplay"),
                .target(name: "MarkdownRendering"),
                .target(name: "UnidocAssets"),
                .target(name: "UnidocRecords"),
                .product(name: "HTTP", package: "servit"),
                .product(name: "Media", package: "servit"),
                .product(name: "UnixCalendar", package: "u"),
                .product(name: "HTML", package: "swift-dom"),
            ]
        ),

        .target(
            name: "UnidocServer",
            dependencies: [
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
                .product(name: "GitHubClient", package: "swift-github"),
                .product(name: "HTTPClient", package: "servit"),
                .product(name: "HTTPServer", package: "servit"),
                .product(name: "HTTPServerRequests", package: "servit"),
                .product(name: "Media", package: "servit"),
                .product(name: "Multiparts", package: "servit"),
            ]
        ),

        .target(
            name: "UnidocServerInsecure",
            dependencies: [
                .target(name: "UnidocServer"),
            ]
        ),

        .target(
            name: "UnidocTesting",
            dependencies: [
                .target(name: "UnidocDB"),
                .target(name: "UnidocLinker"),
                .product(name: "MongoTesting", package: "swift-mongodb"),
            ]
        ),

        .target(
            name: "UnidocUI",
            dependencies: [
                .target(name: "PieCharts"),
                .target(name: "UnidocRender"),
                .target(name: "UnidocAPI"),
                .target(name: "UnidocQueries"),
                .product(name: "GitHubAPI", package: "swift-github"),
                .product(name: "URI", package: "ucf"),
                .product(name: "UnixTime", package: "u"),
            ]
        ),


        .testTarget(
            name: "FingerprintingTests",
            dependencies: [
                .target(name: "Fingerprinting"),
            ]
        ),

        .testTarget(
            name: "MarkdownParsingTests",
            dependencies: [
                .target(name: "MarkdownParsing"),
                .target(name: "MarkdownSemantics"),
            ]
        ),

        .testTarget(
            name: "MarkdownPluginSwiftTests",
            dependencies: [
                .target(name: "MarkdownPluginSwift"),
                .target(name: "MarkdownRendering"),
            ]
        ),

        .testTarget(
            name: "MarkdownRenderingTests",
            dependencies: [
                .target(name: "MarkdownRendering"),
            ]
        ),

        .testTarget(
            name: "PackageMetadataTests",
            dependencies: [
                .target(name: "PackageMetadata"),
                .product(name: "SystemIO", package: "swift-io"),
            ]
        ),

        .testTarget(
            name: "S3Tests",
            dependencies: [
                .target(name: "S3Client"),
            ]
        ),

        .testTarget(
            name: "SemanticVersionTests",
            dependencies: [
                .target(name: "SemanticVersions"),
            ]
        ),

        .testTarget(
            name: "SymbolGraphValidationTests",
            dependencies: [
                .target(name: "SymbolGraphTesting"),
                .product(name: "SystemIO", package: "swift-io"),
            ]
        ),

        .executableTarget(
            name: "SymbolGraphBuilderTests",
            dependencies: [
                .target(name: "SymbolGraphBuilder"),
                .target(name: "Testing_"),
            ]
        ),

        .executableTarget(
            name: "SymbolGraphCompilerTests",
            dependencies: [
                .target(name: "SymbolGraphBuilder"),
                .target(name: "Testing_"),
            ]
        ),

        .testTarget(
            name: "SymbolGraphLinkerTests",
            dependencies: [
                .target(name: "MarkdownRendering"),
                .target(name: "SymbolGraphLinker"),
            ]
        ),

        .testTarget(
            name: "SymbolGraphPartTests",
            dependencies: [
                .target(name: "SymbolGraphParts"),
                .product(name: "SystemIO", package: "swift-io"),
            ]
        ),

        .testTarget(
            name: "SymbolGraphTests",
            dependencies: [
                .target(name: "SymbolGraphs"),
            ]
        ),

        .testTarget(
            name: "SymbolTests",
            dependencies: [
                .target(name: "Symbols"),
            ]
        ),

        .testTarget(
            name: "TopologicalSortingTests",
            dependencies: [
                .target(name: "TopologicalSorting"),
            ]
        ),

        .testTarget(
            name: "UnidocDBTests",
            dependencies: [
                .target(name: "UnidocTesting"),
                .target(name: "SymbolGraphBuilder"),
                .target(name: "SymbolGraphTesting"),
                .product(name: "GitHubClient", package: "swift-github"),
            ]
        ),

        .testTarget(
            name: "UnidocQueryTests",
            dependencies: [
                .target(name: "UnidocQueries"),
                .target(name: "UnidocTesting"),
                .target(name: "SymbolGraphTesting"),
            ]
        ),

        .testTarget(
            name: "UnidocRecordsTests",
            dependencies: [
                .target(name: "UnidocRecords"),
            ]
        ),

        .target(name: "guides", path: "Guides"),
    ]
)

switch ProcessInfo.processInfo.environment["UNIDOC_ENABLE_INDEXSTORE"]?.lowercased() {
case "1"?, "true"?:
    package.dependencies.append(
        .package(
            url: "https://github.com/swiftlang/indexstore-db",
            branch: "main"
        )
    )

    package.targets.append(
        .target(
            name: "MarkdownPluginSwift_IndexStoreDB",
            dependencies: [
                .target(name: "MarkdownPluginSwift"),
                .product(name: "IndexStoreDB", package: "indexstore-db"),
            ]
        )
    )

default:
    package.targets.append(
        .target(
            name: "MarkdownPluginSwift_IndexStoreDB",
            dependencies: [
                .target(name: "MarkdownPluginSwift"),
            ]
        )
    )
}

for target: PackageDescription.Target in package.targets {
    {
        var settings: [PackageDescription.SwiftSetting] = $0 ?? []

        settings.append(.enableUpcomingFeature("ExistentialAny"))
        settings.append(.enableExperimentalFeature("StrictConcurrency"))

        settings.append(.treatWarning("ExistentialAny", as: .error))
        settings.append(.treatWarning("MutableGlobalVariable", as: .error))

        settings.append(.define("DEBUG", .when(configuration: .debug)))

        $0 = settings
    } (&target.swiftSettings)
}

var version: String {
    if  let git: GitInformation = Context.gitInformation {
        let base: String = git.currentTag ?? git.currentCommit
        return git.hasUncommittedChanges ? "\(base) (modified)" : base
    } else {
        return "(untracked)"
    }
}
