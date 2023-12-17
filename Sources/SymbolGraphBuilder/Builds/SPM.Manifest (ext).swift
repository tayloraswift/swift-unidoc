import JSON
import PackageMetadata
import System

extension SPM.Manifest
{
    public static
    func dump(from build:PackageBuild) async throws -> Self
    {
        switch build.id
        {
        case    .unversioned(let package):
            print("Dumping manifest for package '\(package)' (unversioned)")

        case    .versioned(let pin, _),
                .upstream(let pin):
            print("Dumping manifest for package '\(pin.id)' at \(pin.state)")
        }
        //  The manifest can be very large, possibly larger than the 64 KB pipe buffer
        //  limit. So instead of getting the `dump-package` output from a pipe, we
        //  tell the subprocess to write it to a file, and read back the file afterwards.
        let json:JSON
        do
        {
            let path:FilePath = build.output.path / "\(build.id.package).package.json"
            let utf8:[UInt8] = try await path.open(.readWrite,
                permissions: (.rw, .r, .r),
                options: [.create, .truncate])
            {
                let dump:SystemProcess = try .init(command: "swift", "package", "dump-package",
                    "--package-path", "\(build.root)",
                    stdout: $0)
                try await dump()
                return try $0.readAll()
            }

            json = .init(utf8: utf8)
        }
        catch let error
        {
            throw SPM.ManifestDumpError.init(underlying: error, root: build.root)
        }

        return try json.decode()
    }
}
