import ModuleGraphs
import SemanticVersions
import System

@frozen public
struct PackageBuild
{
    /// What is being built.
    let identity:Identity
    /// Where to emit documentation artifacts to.
    let output:Workspace
    /// Where the package root directory is. There should be a `Package.swift`
    /// manifest at the top level of this directory.
    let root:FilePath

    init(identity:Identity, output:Workspace, root:FilePath)
    {
        self.identity = identity
        self.output = output
        self.root = root
    }
}
extension PackageBuild
{
    /// Always returns ``Configuration debug``.
    var configuration:Configuration { .debug }

    var pin:Repository.Pin?
    {
        switch self.identity
        {
        case .unversioned:          return nil
        case .versioned(let pin):   return pin
        }
    }
    var id:PackageIdentifier
    {
        switch self.identity
        {
        case .unversioned(let id):  return id
        case .versioned(let pin):   return pin.id
        }
    }
}
extension PackageBuild
{
    /// Creates a build setup by attaching a package located in a directory of the
    /// same name in the specified location.
    ///
    /// -   Parameters:
    ///     -   package:
    ///         The identifier of the package.
    ///     -   prefix:
    ///         The location in which this function will search for a directory
    ///         named `"\(package)"`.
    ///     -   shared:
    ///         The directory in which this function will create a location to
    ///         dump build artifacts to.
    public static
    func local(package:PackageIdentifier,
        from prefix:FilePath,
        in shared:Workspace,
        clean:Bool = false) async throws -> Self
    {
        .init(identity: .unversioned(package),
            output: try await shared.create("\(package)", clean: clean).create("artifacts"),
            root: prefix / "\(package)")
    }

    /// Clones or pulls the specified package from a git repository, checking out
    /// the specified ref.
    ///
    /// -   Parameters:
    ///     -   package:
    ///         The identifier of the package to check out. This is *usually* the
    ///         same as the last path component of the remote URL.
    ///     -   remote:
    ///         The URL of the git repository to clone or pull from.
    ///     -   refname:
    ///         The ref to check out. This string must match exactly, e.g. `v0.1.0`
    ///         is not equivalent to `0.1.0`.
    ///     -   shared:
    ///         The directory in which this function will create folders.
    public static
    func remote(package:PackageIdentifier,
        from remote:String,
        at refname:String,
        in shared:Workspace,
        clean:Bool = false) async throws -> Self
    {
        let ref:SemanticRef = .infer(from: refname)

        let container:Workspace = try await shared.create("\(package)@\(ref.canonical)",
            clean: clean)
        let checkouts:Workspace = try await container.create("checkouts")
        let artifacts:Workspace = try await container.create("artifacts")
        let cloned:FilePath = checkouts.path / "\(package)"

        do
        {
            try await SystemProcess.init(command: "git", "-C", "\(cloned)", "fetch")()
        }
        catch SystemProcessError.exit
        {
            try await SystemProcess.init(command: "git", "-C", "\(checkouts)",
                "clone", remote, "\(package)")()
        }


        try await SystemProcess.init(command: "git", "-C", "\(cloned)", "checkout", refname)()

        let (readable, writable):(FileDescriptor, FileDescriptor) =
            try FileDescriptor.pipe()

        defer
        {
            try? writable.close()
            try? readable.close()
        }

        try await SystemProcess.init(command: "git", "-C", "\(cloned)",
            "rev-list", "-n", "1", refname,
            stdout: writable)()

        //  Note: output contains trailing newline
        let stdout:String = try .init(unsafeUninitializedCapacity: 64)
        {
            try readable.read(into: .init($0))
        }

        if  let revision:Repository.Revision = .init(stdout.prefix(while: \.isHexDigit))
        {
            let pin:Repository.Pin = .init(id: package,
                location: .remote(url: remote),
                revision: revision,
                ref: ref)
            return .init(identity: .versioned(pin), output: artifacts, root: cloned)
        }
        else
        {
            fatalError("unimplemented")
        }
    }
}
