import PackageMetadata
import System

struct RepositoryContext
{
    let root:FilePath

    private
    init(root:FilePath)
    {
        self.root = root
    }
}
extension RepositoryContext
{
    static
    func setup(cloning repository:String,
        into name:FilePath.Component,
        in workspace:FilePath) async throws -> Self
    {
        let root:FilePath = workspace / name
        do
        {
            let pull:SystemProcess = try .init(command: "git",
                arguments: ["-C", root.string, "pull"])
            try await pull()
        }
        catch SystemProcessError.exit
        {
            let clone:SystemProcess = try .init(command: "git",
                arguments: ["-C", workspace.string, "clone", repository, name.string])
            try await clone()
        }
        return .init(root: root)
    }

    func build() async throws
    {
        let build:SystemProcess = try .init(command: "swift",
            arguments: ["build", "--package-path", self.root.string])
        try await build()
    }

    func loadManifest() async throws -> PackageManifest
    {
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

    func loadResolutions() throws -> PackageResolutions
    {
        try .init(parsing: try (self.root / "Package.resolved").read())
    }
}
