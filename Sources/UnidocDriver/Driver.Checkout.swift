import PackageMetadata
import PackageGraphs
import SemanticVersions
import SymbolGraphs
import System
import UnidocCompiler

extension Driver
{
    @frozen public
    struct Checkout
    {
        let workspace:Workspace
        let root:FilePath
        public
        let pin:Repository.Pin

        init(workspace:Workspace, root:FilePath, pin:Repository.Pin)
        {
            self.workspace = workspace
            self.root = root
            self.pin = pin
        }
    }
}
extension Driver.Checkout
{
    public
    func buildPackage() async throws -> Driver.Artifacts
    {
        print("Building package: \(self.root)")

        let build:SystemProcess = try .init(command: "swift",
            arguments: ["build", "--package-path", self.root.string])
        try await build()

        let resolutions:PackageResolutions = try .init(
            parsing: try (self.root / "Package.resolved").read())

        let toolchain:Driver.Toolchain = try await self.dumpToolchainInfo()
        let manifest:PackageManifest = try await self.dumpManifest()

        print("Note: using spm tools version \(manifest.format)")
        print("Note: using toolchain version \(toolchain.version?.description ?? "<unstable>")")
        print("Note: using toolchain triple '\(toolchain.triple)'")

        let package:(products:[ProductNode], targets:[TargetNode]) = try manifest.graph(
            platform: try toolchain.platform())
        {
            switch $0
            {
            case .library:  return true
            case _:         return false
            }
        }

        let cultures:[Driver.Culture] = try await self.dumpSymbols(package.targets,
            triple: toolchain.triple)

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
        let metadata:SymbolGraph.Metadata = .init(package: self.pin.id,
            triple: toolchain.triple,
            revision: self.pin.revision,
            ref: self.pin.ref,
            requirements: manifest.requirements,
            dependencies: resolutions.pins.map
            {
                .init(package: $0.id,
                    requirement: dependencies[$0.id],
                    revision: $0.revision,
                    ref: $0.ref)
            },
            products: package.products)

        //  Note: the manifest root is the root we want.
        //  (`self.root` may be a relative path.)
        return .init(metadata: metadata, cultures: cultures, root: manifest.root)
    }
}
extension Driver.Checkout
{
    public
    func dumpToolchainInfo() async throws -> Driver.Toolchain
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

    public
    func dumpManifest() async throws -> PackageManifest
    {
        print("Dumping manifest for package '\(self.pin.id)' at \(self.pin.state)")
        //  The manifest can be very large, possibly larger than the 64 KB pipe buffer
        //  limit. So instead of getting the `dump-package` output from a pipe, we
        //  tell the subprocess to write it to a file, and read back the file afterwards.
        let path:FilePath = self.root / "Package.swift.json"
        let json:String = try await path.open(.readWrite,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            let dump:SystemProcess = try .init(command: "swift",
                arguments: ["package", "--package-path", self.root.string, "dump-package"],
                stdout: $0)
            try await dump()
            return try $0.readAll()
        }
        return try .init(parsing: json)
    }

    public
    func dumpSymbols(_ targets:[TargetNode],
        triple:Triple,
        pretty:Bool = false) async throws -> [Driver.Culture]
    {
        for target:TargetNode in targets
        {
            print("Dumping symbols for module '\(target.id)'")

            try await SystemProcess.init(command: "swift", "symbolgraph-extract",
                "-I", "\(self.root)/.build/debug",
                "-target", "\(triple)",
                "-minimum-access-level", "internal",
                "-output-dir", "\(self.workspace.path)",
                "-skip-inherited-docs",
                "-emit-extension-block-symbols",
                "-include-spi-symbols",
                pretty ? "-pretty-print" : nil,
                "-module-name", "\(target.id)")()
        }

        var parts:[ModuleIdentifier: [FilePath.Component]] = [:]
        for part:Result<FilePath.Component, any Error> in self.workspace.path.directory
        {
            let part:FilePath.Component = try part.get()
            let names:[Substring] = part.string.split(separator: ".")
            //  We don’t want to *parse* the JSON yet to discover the culture,
            //  because the JSON can be very large, and parsing JSON is very
            //  expensive (compared to parsing BSON). So we trust that the
            //  file name is correct and indicates what is contained within the
            //  file.
            if  names.count == 3,
                names[1 ... 2] == ["symbols", "json"],
                let culture:Substring = names[0].split(separator: "@", maxSplits: 1).first
            {
                parts[.init(String.init(culture)), default: []].append(part)
            }
        }

        return try targets.map
        {
            try .init(
                parts: parts[$0.id, default: []].map { self.workspace.path / $0 },
                node: $0)
        }
    }
}
