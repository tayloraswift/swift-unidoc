import PackageMetadata
import Repositories
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

        let _:PackageResolutions = try .init(
            parsing: try (self.root / "Package.resolved").read())

        let manifest:PackageManifest = try await self.dumpManifest()
        let targets:[PackageManifest.Target] = try manifest.libraries()
        let cultures:[Driver.Culture] = try await self.dumpSymbols(targets.map(\.id.mangled))

        //  TODO: actually populate this correctly
        let _metadata:SymbolGraph.Metadata = .init(package: self.pin.id, at: self.pin.reference)

        //  Note: the manifest root is the root we want.
        //  (`self.root` may be a relative path.)
        return .init(metadata: _metadata, cultures: cultures, root: manifest.root)
    }
}
extension Driver.Checkout
{
    public
    func dumpManifest() async throws -> PackageManifest
    {
        print("""
            Dumping manifest for package '\(self.pin.id)' \
            at \(self.pin.reference) (\(self.pin.revision))
            """)
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
    func dumpSymbols(_ modules:[ModuleIdentifier]) async throws -> [Driver.Culture]
    {
        // for module:ModuleIdentifier in modules
        // {
        //     print("Dumping symbols for module '\(module)'")

        //     try await SystemProcess.init(command: "swift", "symbolgraph-extract",
        //         "-I", "\(self.root)/.build/debug",
        //         "-target", "x86_64-unknown-linux-gnu",
        //         "-minimum-access-level", "internal",
        //         "-output-dir", "\(self.workspace.path)",
        //         "-skip-inherited-docs",
        //         "-emit-extension-block-symbols",
        //         "-include-spi-symbols",
        //         "-pretty-print",
        //         "-module-name", "\(module)")()
        // }

        var parts:[ModuleIdentifier: [FilePath.Component]] = [:]
        for try await part:FilePath.Component in self.workspace.path.directory
        {
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

        return try modules.map
        {
            try .init(module: $0, parts: parts[$0, default: []].map
            {
                self.workspace.path / $0
            })
        }
    }
}
