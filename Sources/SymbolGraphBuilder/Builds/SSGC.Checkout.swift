import SHA1
import Symbols
import System_
import UnixTime

extension SSGC
{
    struct Checkout
    {
        /// Absolute path to the checkout directory.
        let location:FilePath.Directory
        let revision:SHA1
        let date:UnixMillisecond

        private
        init(location:FilePath.Directory, revision:SHA1, date:UnixMillisecond)
        {
            self.location = location
            self.revision = revision
            self.date = date
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

        // Get the SHA-1 hash of the current commit
        try SystemProcess.init(command: "git", "-C", "\(clone)",
            "rev-list", "-n", "1", reference,
            stdout: writable)()

        let revisionLine:String = try .init(unsafeUninitializedCapacity: 64)
        {
            try readable.read(into: .init($0))
        }

        //  Get the timestamp of the current commit, in seconds since the Unix epoch.
        //  64 bytes should be enough for any Unix timestamp.
        try SystemProcess.init(command: "git", "-C", "\(clone)",
            "log", "-1", "--format=%ct",
            stdout: writable)()

        let unixSecondLine:String = try .init(unsafeUninitializedCapacity: 64)
        {
            try readable.read(into: .init($0))
        }

        //  Note: output lines contains trailing newline
        guard
        let revision:SHA1 = .init(revisionLine.prefix(while: { !$0.isNewline }))
        else
        {
            fatalError("Could not parse revision from git output: \(revisionLine)")
        }

        guard
        let unixSecond:Int64 = .init(unixSecondLine.prefix(while: { !$0.isNewline }))
        else
        {
            fatalError("Could not parse date from git output: \(unixSecondLine)")
        }

        return .init(location: clone, revision: revision, date: .init(index: unixSecond))
    }
}
