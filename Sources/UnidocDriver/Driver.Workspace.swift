import PackageGraphs
import SemanticVersions
import System

extension Driver
{
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
}
extension Driver.Workspace
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
        try await SystemProcess.init(command: "rm", "\(self.path.appending("*"))")()
    }

    public
    func checkout(url:String,
        at ref:String,
        clean:Bool = false) async throws -> Driver.Checkout
    {
        guard let package:PackageIdentifier = .infer(from: url)
        else
        {
            fatalError("unimplemented")
        }

        let root:FilePath = self.path / "\(package)"
        do
        {
            try await SystemProcess.init(command: "git", "-C", root.string, "fetch")()
        }
        catch SystemProcessError.exit
        {
            try await SystemProcess.init(command: "git", "-C", self.path.string,
                "clone", url, package.description)()
        }

        let workspace:Self = try await .create(at: self.path / "\(package).doc")
        if  clean { try await workspace.clean() }

        try await SystemProcess.init(command: "git", "-C", root.string, "checkout", ref)()

        let (readable, writable):(FileDescriptor, FileDescriptor) =
            try FileDescriptor.pipe()

        defer
        {
            try? writable.close()
            try? readable.close()
        }

        try await SystemProcess.init(command: "git", "-C", root.string,
            "rev-list", "-n", "1", ref,
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
                ref: .infer(from: ref)))
    }
}
