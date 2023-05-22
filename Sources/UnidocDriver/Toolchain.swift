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
    func generateArtifactsForStandardLibrary(
        in workspace:Workspace,
        pretty:Bool = false) async throws -> DocumentationArtifacts
    {
        //  https://forums.swift.org/t/dependency-graph-of-the-standard-library-modules/59267
        let cultures:[DocumentationArtifacts.Culture] = try await workspace.dumpSymbols(
            targets:
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
            triple: self.triple,
            pretty: pretty)

        let products:[ProductNode] =
        [
            .init(name: "__stdlib__",
                type: .library(.automatic),
                dependencies: .init(modules: [Int].init(0 ... 7))),
            .init(name: "__corelibs__",
                type: .library(.automatic),
                dependencies: .init(modules: [Int].init(cultures.indices))),
        ]

        let metadata:DocumentationMetadata = .swift(triple: self.triple, version: self.version,
            products: products)

        return .init(metadata: metadata, cultures: cultures)
    }
    public
    func generateArtifactsForPackage(
        in checkout:RepositoryCheckout,
        pretty:Bool = false) async throws -> DocumentationArtifacts
    {
        print("Building package in: \(checkout.root)")

        let build:SystemProcess = try .init(command: "swift",
            arguments: ["build", "--package-path", checkout.root.string])
        try await build()

        let resolutions:PackageResolutions = try .init(
            parsing: try (checkout.root / "Package.resolved").read())

        let manifest:PackageManifest = try await checkout.dumpManifest()

        print("Note: using spm tools version \(manifest.format)")

        let package:(products:[ProductNode], targets:[TargetNode]) = try manifest.graph(
            platform: try self.platform())
        {
            switch $0
            {
            case .library:  return true
            case _:         return false
            }
        }

        let cultures:[DocumentationArtifacts.Culture] = try await checkout.dumpSymbols(
            targets: package.targets,
            triple: self.triple,
            pretty: pretty)

        //  Index repository dependencies
        var dependencies:[PackageIdentifier: Repository.Requirement] = [:]
        for dependency:PackageManifest.Dependency in manifest.dependencies
        {
            if  case .resolvable(let dependency) = dependency,
                case .stable(let requirement) = dependency.requirement
            {
                dependencies[dependency.id] = requirement
            }
        }
        let metadata:DocumentationMetadata = .init(package: checkout.pin.id,
            triple: self.triple,
            ref: checkout.pin.ref,
            dependencies: resolutions.pins.map
            {
                .init(package: $0.id,
                    requirement: dependencies[$0.id],
                    revision: $0.revision,
                    ref: $0.ref)
            },
            toolchain: self.version,
            products: package.products,
            requirements: manifest.requirements,
            revision: checkout.pin.revision)

        //  Note: the manifest root is the root we want.
        //  (`self.root` may be a relative path.)
        return .init(metadata: metadata, cultures: cultures, root: manifest.root)
    }

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
