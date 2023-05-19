import PackageMetadata
import PackageGraphs
import System

@frozen public
struct RepositoryCheckout
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
extension RepositoryCheckout
{
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
    func dumpSymbols(targets:[TargetNode],
        triple:Triple,
        pretty:Bool = false) async throws -> [DocumentationArtifacts.Culture]
    {
        try await self.workspace.dumpSymbols(targets,
            include: self.root / ".build" / "debug",
            triple: triple,
            pretty: pretty)
    }
}
