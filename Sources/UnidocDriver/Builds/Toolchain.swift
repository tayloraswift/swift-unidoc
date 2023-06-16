import ModuleGraphs
import PackageGraphs
import PackageMetadata
import SemanticVersions
import SymbolGraphs
import System

@frozen public
struct Toolchain
{
    public
    let version:SemanticRef
    public
    let triple:Triple

    @inlinable public
    init(version:SemanticRef, triple:Triple)
    {
        self.version = version
        self.triple = triple
    }
}
extension Toolchain
{
    public static
    func detect() async throws -> Self
    {
        let (readable, writable):(FileDescriptor, FileDescriptor) =
        try FileDescriptor.pipe()

        defer
        {
            try? writable.close()
            try? readable.close()
        }

        try await SystemProcess.init(command: "swift", "--version", stdout: writable)()
        return try .init(parsing: try readable.read(buffering: 1024))
    }

    private
    init(parsing splash:String) throws
    {
        //  Splash should consist of two complete lines of the form
        //
        //  Swift version 5.8 (swift-5.8-RELEASE)
        //  Target: x86_64-unknown-linux-gnu
        let lines:[Substring] = splash.split(separator: "\n", omittingEmptySubsequences: false)
        //  if the final newline isn’t present, the output was clipped.
        guard lines.count == 3
        else
        {
            throw ToolchainError.malformedSplash
        }

        let toolchain:[Substring] = lines[0].split(separator: " ")
        let triple:[Substring] = lines[1].split(separator: " ")

        guard   toolchain.count >= 4,
                toolchain[0 ... 1] == ["Swift", "version"],
                triple.count == 2,
                triple[0] == "Target:"
        else
        {
            throw ToolchainError.malformedSplash
        }

        if  let triple:Triple = .init(triple[1])
        {
            self.init(version: .infer(from: toolchain[2]), triple: triple)
        }
        else
        {
            throw ToolchainError.malformedTriple
        }
    }
}
extension Toolchain
{
    public
    func generateDocs(for build:ToolchainBuild,
        pretty:Bool = false) async throws -> Documentation
    {
        //  https://forums.swift.org/t/dependency-graph-of-the-standard-library-modules/59267
        let artifacts:Artifacts = try await .dump(
            modules:
            [
                //  0:
                .init(name: "Swift", type: .binary,
                    dependencies: .init()),
                //  1:
                .init(name: "_Concurrency", type: .binary,
                    dependencies: .init(modules: [0])),
                //  2:
                .init(name: "Distributed", type: .binary,
                    dependencies: .init(modules: [0, 1])),

                //  3:
                .init(name: "_Differentiation", type: .binary,
                    dependencies: .init(modules: [0])),

                //  4:
                .init(name: "_RegexParser", type: .binary,
                    dependencies: .init(modules: [0])),
                //  5:
                .init(name: "_StringProcessing", type: .binary,
                    dependencies: .init(modules: [0, 4])),
                //  6:
                .init(name: "RegexBuilder", type: .binary,
                    dependencies: .init(modules: [0, 4, 5])),

                //  7:
                .init(name: "Cxx", type: .binary,
                    dependencies: .init(modules: [0])),

                //  8:
                .init(name: "Dispatch", type: .binary,
                    dependencies: .init(modules: [0])),
                //  9:
                .init(name: "DispatchIntrospection", type: .binary,
                    dependencies: .init(modules: [0])),
                // 10:
                .init(name: "Foundation", type: .binary,
                    dependencies: .init(modules: [0, 8])),
                // 11:
                .init(name: "FoundationNetworking", type: .binary,
                    dependencies: .init(modules: [0, 8, 10])),
                // 12:
                .init(name: "FoundationXML", type: .binary,
                    dependencies: .init(modules: [0, 8, 10])),
            ],
            output: build.output,
            triple: self.triple,
            pretty: pretty)

        let products:[ProductDetails] =
        [
            .init(name: "__stdlib__",
                type: .library(.automatic),
                dependencies: .init(modules: [Int].init(0 ... 7))),
            .init(name: "__corelibs__",
                type: .library(.automatic),
                dependencies: .init(modules: [Int].init(artifacts.cultures.indices))),
        ]

        let metadata:Documentation.Metadata = .swift(triple: self.triple,
            version: self.version,
            products: products)

        return .init(metadata: metadata, graph: try await .build(from: artifacts))
    }
    public
    func generateDocs(for build:PackageBuild,
        pretty:Bool = false) async throws -> Documentation
    {
        let manifest:PackageManifest = try await .dump(from: build)

        print("Building package: '\(build.id)' (swift-tools-version: \(manifest.format))")

        //  Don’t parrot the `swift build` output to the terminal
        let log:FilePath = build.output.path / "build.log"
        try await log.open(.writeOnly,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            try await SystemProcess.init(command: "swift",
                "build",
                "--configuration", "\(build.configuration)",
                "--package-path", "\(build.root)",
                stdout: $0)()
        }

        let pins:[Repository.Pin]
        do
        {
            let resolutions:PackageResolutions = try .init(
                parsing: try (build.root / "Package.resolved").read())
            pins = resolutions.pins
        }
        catch is FileError
        {
            pins = []
        }

        let platform:PlatformIdentifier = try self.platform()
        let sink:PackageNode = try .libraries(as: build.id,
            flattening: manifest,
            platform: platform)

        var dependencies:[PackageNode] = []
        var include:[FilePath] =
        [
            .init(manifest.root.path) / ".build" / "\(build.configuration)"
        ]
        for pin:Repository.Pin in pins
        {
            let manifest:PackageManifest = try await .dump(from: .init(
                identity: .versioned(pin),
                output: build.output,
                root: build.root / ".build" / "checkouts" / "\(pin.id)"))

            let upstream:PackageNode = try .libraries(as: pin.id,
                flattening: manifest,
                platform: platform)
            let sources:PackageSources = try .init(scanning: upstream)

            sources.yield(include: &include)
            dependencies.append(upstream)
        }

        let package:PackageNode = try sink.flattened(dependencies: dependencies)
        let artifacts:Artifacts = try await .dump(from: package,
            include: &include,
            output: build.output,
            triple: self.triple,
            pretty: pretty)

        let metadata:Documentation.Metadata = .init(package: build.id,
            triple: self.triple,
            ref: build.pin?.ref,
            dependencies: try package.pinnedDependencies(using: pins),
            toolchain: self.version,
            products: package.products,
            requirements: manifest.requirements,
            revision: build.pin?.revision)

        return .init(metadata: metadata, graph: try await .build(from: artifacts))
    }
}
extension Toolchain
{
    private
    func platform() throws -> PlatformIdentifier
    {
        if      self.triple.os.starts(with: "linux")
        {
            return .linux
        }
        else if self.triple.os.starts(with: "ios")
        {
            return .iOS
        }
        else if self.triple.os.starts(with: "macos")
        {
            return .macOS
        }
        else if self.triple.os.starts(with: "tvos")
        {
            return .tvOS
        }
        else if self.triple.os.starts(with: "watchos")
        {
            return .watchOS
        }
        else if self.triple.os.starts(with: "windows")
        {
            return .windows
        }
        else
        {
            throw ToolchainError.unsupportedTriple(self.triple)
        }
    }
}
