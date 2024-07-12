import SHA1
import Symbols
import System

extension SSGC
{
    struct Checkout
    {
        /// Absolute path to the checkout directory.
        let location:FilePath.Directory
        let revision:SHA1

        private
        init(location:FilePath.Directory, revision:SHA1)
        {
            self.location = location
            self.revision = revision
        }
    }
}
extension SSGC.Checkout
{
    static
    func checkout(project name:Symbol.Package,
        from repository:String,
        at reference:String,
        in workspace:SSGC.Workspace,
        clean:Bool = false) throws -> Self
    {
        //  The directory layout looks something like:
        //
        //  myworkspace/
        //  ├── artifacts/
        //  └── checkouts/
        //      └── swift-example-package/
        //          ├── .git/
        //          ├── .build/
        //          ├── .build.unidoc/
        //          ├── Package.swift
        //          └── ...

        let clone:FilePath.Directory = workspace.checkouts / "\(name)"
        if  clean
        {
            try clone.remove()
        }

        if  repository.starts(with: "https://x-access-token:")
        {
            print("WARNING: redacted repository URL because it contains an access token.")
        }
        else
        {
            print("Pulling repository from remote: \(repository)")
        }

        if  clone.exists()
        {
            try SystemProcess.init(command: "git", "-C", "\(clone)", "fetch")()
        }
        else
        {
            try SystemProcess.init(command: "git", "-C", "\(workspace.checkouts)",
                "clone", repository, "\(name)", "--recurse-submodules")()
        }

        try SystemProcess.init(command: "git", "-C", "\(clone)",
            "-c", "advice.detachedHead=false",
            "checkout", "-f", reference,
            "--recurse-submodules")()

        let (readable, writable):(FileDescriptor, FileDescriptor) =
            try FileDescriptor.pipe()

        defer
        {
            try? writable.close()
            try? readable.close()
        }

        try SystemProcess.init(command: "git", "-C", "\(clone)",
            "rev-list", "-n", "1", reference,
            stdout: writable)()

        //  Note: output contains trailing newline
        let stdout:String = try .init(unsafeUninitializedCapacity: 64)
        {
            try readable.read(into: .init($0))
        }

        guard
        let revision:SHA1 = .init(stdout.prefix(while: \.isHexDigit))
        else
        {
            fatalError("unimplemented")
        }

        return .init(location: clone, revision: revision)
    }
}
