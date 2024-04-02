import SymbolGraphs
import System

extension SSGC
{
    public
    struct StdlibBuild
    {
        /// Where to emit documentation artifacts to.
        let artifacts:ArtifactsDirectory

        private
        init(artifacts:ArtifactsDirectory)
        {
            self.artifacts = artifacts
        }
    }
}
extension SSGC.StdlibBuild
{
    public static
    func swift(in shared:SSGC.Workspace, clean:Bool = false) async throws -> Self
    {
        let container:SSGC.Workspace = try await shared.create("swift", clean: clean)
        return .init(artifacts: try await container.create("artifacts", clean: clean,
            as: ArtifactsDirectory.self)) // https://github.com/apple/swift/issues/71602
    }
}
extension SSGC.StdlibBuild:SSGC.DocumentationBuild
{
    func compile(
        with swift:SSGC.Toolchain,
        logs _:inout Logs) async throws -> (SymbolGraphMetadata, SSGC.PackageSources)
    {
        //  https://forums.swift.org/t/dependency-graph-of-the-standard-library-modules/59267
        let sources:[SSGC.NominalSources] =
        [
            //  0:
            .toolchain(module: "Swift"),
            //  1:
            .toolchain(module: "_Concurrency",
                dependencies: 0),
            //  2:
            .toolchain(module: "Distributed",
                dependencies: 0, 1),

            //  3:
            .toolchain(module: "_Differentiation",
                dependencies: 0),

            //  4:
            .toolchain(module: "_RegexParser",
                dependencies: 0),
            //  5:
            .toolchain(module: "_StringProcessing",
                dependencies: 0, 4),
            //  6:
            .toolchain(module: "RegexBuilder",
                dependencies: 0, 4, 5),

            //  7:
            .toolchain(module: "Cxx",
                dependencies: 0),

            //  8:
            .toolchain(module: "Dispatch",
                dependencies: 0),
            //  9:
            .toolchain(module: "DispatchIntrospection",
                dependencies: 0),
            // 10:
            .toolchain(module: "Foundation",
                dependencies: 0, 8),
            // 11:
            .toolchain(module: "FoundationNetworking",
                dependencies: 0, 8, 10),
            // 12:
            .toolchain(module: "FoundationXML",
                dependencies: 0, 8, 10),
            // 12:
            .toolchain(module: "XCTest",
                dependencies: 0),
        ]

        let metadata:SymbolGraphMetadata = .swift(swift.version,
            commit: swift.commit,
            triple: swift.triple,
            products:
            [
                .init(name: "__stdlib__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(0 ... 7)),
                .init(name: "__corelibs__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(sources.indices)),
            ])

        return (metadata, .init(cultures: sources))
    }
}
