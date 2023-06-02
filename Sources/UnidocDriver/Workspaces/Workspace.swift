import ModuleGraphs
import SemanticVersions
import System

@frozen public
struct Workspace:Equatable
{
    public
    let path:FilePath

    @inlinable public
    init(path:FilePath)
    {
        self.path = path
    }
}
extension Workspace
{
    public static
    func create(at path:FilePath) async throws -> Self
    {
        try await SystemProcess.init(command: "mkdir", "-p", "\(path)")()
        return .init(path: path)
    }

    public
    func clean() async throws
    {
        try await SystemProcess.init(command: "rm", "-f", "\(self.path.appending("*"))")()
    }
}
extension Workspace
{
    /// Creates a nested workspace directory within this one.
    public
    func create(_ name:String, clean:Bool = false) async throws -> Self
    {
        let workspace:Self = try await .create(at: self.path / name)
        if  clean { try await workspace.clean() }
        return workspace
    }

    public
    func checkout(url:String,
        at refname:String,
        clean:Bool = false) async throws -> RepositoryCheckout
    {
        guard let package:PackageIdentifier = .infer(from: url)
        else
        {
            fatalError("unimplemented")
        }

        let ref:SemanticRef = .infer(from: refname)

        let workspace:Self = try await self.create("\(package)@\(ref.canonical)", clean: clean)
        let root:FilePath = workspace.path / "\(package)"

        do
        {
            try await SystemProcess.init(command: "git", "-C", root.string, "fetch")()
        }
        catch SystemProcessError.exit
        {
            try await SystemProcess.init(command: "git", "-C", workspace.path.string,
                "clone", url, package.description)()
        }


        try await SystemProcess.init(command: "git", "-C", root.string, "checkout", refname)()

        let (readable, writable):(FileDescriptor, FileDescriptor) =
            try FileDescriptor.pipe()

        defer
        {
            try? writable.close()
            try? readable.close()
        }

        try await SystemProcess.init(command: "git", "-C", root.string,
            "rev-list", "-n", "1", refname,
            stdout: writable)()

        //  Note: output contains trailing newline
        let output:String = try .init(unsafeUninitializedCapacity: 64)
        {
            try readable.read(into: .init($0))
        }

        guard let revision:Repository.Revision = .init(output.prefix(while: \.isHexDigit))
        else
        {
            fatalError("unimplemented")
        }

        return .init(workspace: workspace,
            root: root,
            pin: .init(id: package,
                location: .remote(url: url),
                revision: revision,
                ref: ref))
    }
}
