import PackageGraphs
import PackageMetadata
import SemanticVersions
import SymbolGraphs
import Symbols
import System

@frozen public
struct Toolchain
{
    public
    let version:AnyVersion
    public
    let tagname:String
    public
    let triple:Triple

    private
    init(version:AnyVersion, tagname:String, triple:Triple)
    {
        self.version = version
        self.tagname = tagname
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

        //  Swift version 5.8-dev (LLVM 07d14852a049e40, Swift 613b3223d9ec5f6)
        //  Target: x86_64-unknown-linux-gnu
        if  toolchain.count > 4
        {
            throw ToolchainError.developmentSnapshotNotSupported
        }

        let parenthesized:Substring = toolchain[3]

        guard parenthesized.startIndex < parenthesized.endIndex
        else
        {
            throw ToolchainError.malformedSplash
        }

        let i:String.Index = parenthesized.index(after: parenthesized.startIndex)
        let j:String.Index = parenthesized.index(before: parenthesized.endIndex)

        guard   i < j,
        case ("(", ")") = (parenthesized[parenthesized.startIndex], parenthesized[j])
        else
        {
            throw ToolchainError.malformedSplash
        }

        if  let triple:Triple = .init(triple[1])
        {

            self.init(
                version: .init(toolchain[2]),
                tagname: .init(parenthesized[i ..< j]),
                triple: triple)
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
        pretty:Bool = false) async throws -> SymbolGraphArchive
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

        let metadata:SymbolGraphMetadata = .swift(self.version,
            tagname: self.tagname,
            triple: self.triple,
            products:
            [
                .init(name: "__stdlib__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(0 ... 7)),
                .init(name: "__corelibs__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(artifacts.cultures.indices)),
            ])

        return .init(metadata: metadata, graph: try await .build(from: artifacts))
    }
    public
    func generateDocs(for build:PackageBuild,
        pretty:Bool = false) async throws -> SymbolGraphArchive
    {
        let manifest:SPM.Manifest = try await .dump(from: build)

        print("""
            Building package: '\(build.id.package)' \
            (swift-tools-version: \(manifest.format))
            """)

        //  Don’t parrot the `swift package resolve` output to the terminal
        let resolutionLog:FilePath = build.output.path / "resolution.log"
        try await resolutionLog.open(.writeOnly,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            try await SystemProcess.init(command: "swift",
                "package",
                "resolve",
                "--package-path", "\(build.root)",
                stdout: $0)()
        }

        //  Don’t parrot the `swift build` output to the terminal
        let buildLog:FilePath = build.output.path / "build.log"

        print("""
            Building package: '\(build.id.package)', \
            streaming output to '\(buildLog)'
            """)

        try await buildLog.open(.writeOnly,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            try await SystemProcess.init(command: "swift",
                "build",
                "--configuration", "\(build.configuration)",
                "--package-path", "\(build.root)",
                stdout: $0)()
        }

        let pins:[SPM.DependencyPin]
        do
        {
            let resolutions:SPM.DependencyResolutions = try .init(
                parsing: try (build.root / "Package.resolved").read())
            pins = resolutions.pins
        }
        catch is FileError
        {
            pins = []
        }

        let platform:SymbolGraphMetadata.Platform = try self.platform()

        var dependencies:[PackageNode] = []
        var include:[FilePath] =
        [
            .init(manifest.root.path) / ".build" / "\(build.configuration)"
        ]
        for pin:SPM.DependencyPin in pins
        {
            let checkout:FilePath = build.root / ".build" / "checkouts" / "\(pin.location.name)"

            let manifest:SPM.Manifest = try await .dump(from: .init(id: .upstream(pin),
                output: build.output,
                root: checkout))

            let dependency:PackageNode = try .all(flattening: manifest,
                on: platform,
                as: pin.id)

            let sources:PackageBuild.Sources = try .init(scanning: dependency)
                sources.yield(include: &include)

            dependencies.append(dependency)
        }

        let sinkNode:PackageNode = try .all(flattening: manifest,
            on: platform,
            as: build.id.package)
        let flatNode:PackageNode = try sinkNode.flattened(dependencies: dependencies)
        let artifacts:Artifacts = try await .dump(from: flatNode,
            include: &include,
            output: build.output,
            triple: self.triple,
            pretty: pretty)

        let commit:SymbolGraphMetadata.Commit?
        if  case .versioned(let pin, let ref) = build.id
        {
            commit = .init(pin.revision, refname: ref)
        }
        else
        {
            commit = nil
        }

        let dependenciesPinned:[SymbolGraphMetadata.Dependency] = try flatNode.pin(to: pins)
        let dependenciesUsed:Set<Symbol.Package> = flatNode.products.reduce(into: [])
        {
            guard
            case .library = $1.type
            else
            {
                return
            }
            for dependency:Symbol.Product in $1.dependencies
            {
                $0.insert(dependency.package)
            }
        }

        let metadata:SymbolGraphMetadata = .init(package: build.id.package,
            commit: commit,
            triple: self.triple,
            swift: self.version,
            requirements: manifest.requirements,
            dependencies: dependenciesPinned.filter { dependenciesUsed.contains($0.package) },
            products: .init(viewing: flatNode.products),
            display: manifest.name,
            root: manifest.root)

        return .init(metadata: metadata, graph: try await .build(from: artifacts))
    }
}
extension Toolchain
{
    private
    func platform() throws -> SymbolGraphMetadata.Platform
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
