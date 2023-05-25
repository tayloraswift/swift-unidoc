import PackageMetadata
import System

extension PackageManifest
{
    public static
    func dump(from checkout:RepositoryCheckout) async throws -> Self
    {
        print("Dumping manifest for package '\(checkout.pin.id)' at \(checkout.pin.state)")
        //  The manifest can be very large, possibly larger than the 64 KB pipe buffer
        //  limit. So instead of getting the `dump-package` output from a pipe, we
        //  tell the subprocess to write it to a file, and read back the file afterwards.
        let path:FilePath = checkout.workspace.path / "\(checkout.pin.id).package.json"
        let json:String = try await path.open(.readWrite,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            let dump:SystemProcess = try .init(command: "swift",
                arguments: ["package", "--package-path", checkout.root.string, "dump-package"],
                stdout: $0)
            try await dump()
            return try $0.readAll()
        }
        return try .init(parsing: json)
    }
}
