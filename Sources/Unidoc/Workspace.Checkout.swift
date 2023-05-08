import PackageMetadata
import Repositories
import System

extension Workspace
{
    struct Checkout
    {
        let root:FilePath
        let pin:Repository.Pin

        init(root:FilePath, pin:Repository.Pin)
        {
            self.root = root
            self.pin = pin
        }
    }
}
extension Workspace.Checkout
{
    func build() async throws
    {
        let build:SystemProcess = try .init(command: "swift",
            arguments: ["build", "--package-path", self.root.string])
        try await build()
    }

    func loadResolutions() throws -> PackageResolutions
    {
        try .init(parsing: try (self.root / "Package.resolved").read())
    }

    func loadManifest() async throws -> PackageManifest
    {
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
}
