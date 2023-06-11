import PackageMetadata
import System

extension PackageManifest
{
    public static
    func dump(from build:PackageBuild) async throws -> Self
    {
        switch build.identity
        {
        case .unversioned:
            print("Dumping manifest for package '\(build.id)' (unversioned)")

        case .versioned(let pin):
            print("Dumping manifest for package '\(build.id)' at \(pin.state)")
        }
        //  The manifest can be very large, possibly larger than the 64 KB pipe buffer
        //  limit. So instead of getting the `dump-package` output from a pipe, we
        //  tell the subprocess to write it to a file, and read back the file afterwards.
        let path:FilePath = build.output.path / "\(build.id).package.json"
        let json:String = try await path.open(.readWrite,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            let dump:SystemProcess = try .init(command: "swift", "package", "dump-package",
                "--package-path", "\(build.root)",
                stdout: $0)
            try await dump()
            return try $0.readAll()
        }
        return try .init(parsing: json)
    }
}
