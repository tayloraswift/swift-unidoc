import BSONEncoding
import ModuleGraphs
import SymbolGraphs
import SymbolGraphBuilder
import System

struct Massbuilder
{
    let toolchain:Toolchain
    let workspace:Workspace

    init() async throws
    {
        self.toolchain = try await .detect()
        self.workspace = try await .create(at: ".massbuild")
    }
}
extension Massbuilder
{
    func build(_ package:PackageIdentifier, repository:String, versions:String...) async throws
    {
        for version:String in versions
        {
            try await self.build(package, repository: repository, at: version)
        }
    }

    func build(_ package:PackageIdentifier,
        repository:String,
        at version:String) async throws
    {
        guard let file:FilePath = self.output(for: package, at: version)
        else
        {
            return
        }

        let docs:SymbolGraphArchive = try await self.toolchain.generateDocs(
            for: try await .remote(
                package: package,
                from: repository,
                at: version,
                in: self.workspace,
                clean: true),
            pretty: true)

        let bson:BSON.Document = .init(encoding: docs)
        try file.overwrite(with: bson.bytes)
    }

    func buildLiterature() async throws
    {
        guard let file:FilePath = self.output(for: "__swiftinit", at: "0.0.0")
        else
        {
            return
        }

        var docs:SymbolGraphArchive = try await toolchain.generateDocs(
            for: try await .local(package: "swiftinit",
                from: "TestPackages",
                in: workspace,
                clean: true),
            pretty: false)

        docs.metadata.package = "__swiftinit"

        let bson:BSON.Document = .init(encoding: docs)
        try file.overwrite(with: bson.bytes)
    }

    func buildStandardLibrary() async throws
    {
        guard let file:FilePath = self.output(for: .swift, at: "\(toolchain.version)")
        else
        {
            return
        }

        let docs:SymbolGraphArchive = try await self.toolchain.generateDocs(
            for: try await .swift(in: self.workspace, clean: true),
            pretty: false)

        let bson:BSON.Document = .init(encoding: docs)
        try file.overwrite(with: bson.bytes)
    }
}
extension Massbuilder
{
    private
    func output(for package:PackageIdentifier, at version:String) -> FilePath?
    {
        let file:FilePath = self.workspace.path / "\(package)@\(version).bson"

        if  let status:FileStatus = try? .status(of: file),
                status.is(.regular)
        {
            print("Skipping \(package)@\(version) (already built)")
            return nil
        }
        else
        {
            print("Building \(package)@\(version)...")
            return file
        }
    }
}
