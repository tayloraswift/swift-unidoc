import SymbolGraphs

extension Toolchain
{
    @frozen public
    struct Build
    {
        /// Where to emit documentation artifacts to.
        let output:SPM.ArtifactDirectory

        private
        init(output:SPM.ArtifactDirectory)
        {
            self.output = output
        }
    }
}
extension Toolchain.Build
{
    public static
    func swift(in shared:SPM.Workspace, clean:Bool = false) async throws -> Self
    {
        let container:SPM.Workspace = try await shared.create("swift", clean: clean)
        return .init(output: try await container.create("artifacts"))
    }
}
extension Toolchain.Build:DocumentationBuild
{
    func compile(with swift:Toolchain,
        pretty:Bool) async throws -> (SymbolGraphMetadata, SPM.Artifacts)
    {
        //  https://forums.swift.org/t/dependency-graph-of-the-standard-library-modules/59267
        let artifacts:SPM.Artifacts = try await swift.dump(
            modules:
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
            ],
            output: self.output,
            triple: swift.triple,
            pretty: pretty)

        let metadata:SymbolGraphMetadata = .swift(swift.version,
            tagname: swift.tagname,
            triple: swift.triple,
            products:
            [
                .init(name: "__stdlib__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(0 ... 7)),
                .init(name: "__corelibs__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(artifacts.cultures.indices)),
            ])

        return (metadata, artifacts)
    }
}
