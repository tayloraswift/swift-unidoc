import Repositories
import SemanticVersions
import System

struct Workspace
{
    let path:FilePath

    private
    init(path:FilePath)
    {
        self.path = path
    }
}
extension Workspace
{
    static
    func create(at path:FilePath) async throws -> Self
    {
        try await SystemProcess.init(command: "mkdir", arguments: ["-p", path.string])()
        return .init(path: path)
    }

    func checkout(url:String, at reference:String) async throws -> Checkout
    {
        guard let package:PackageIdentifier = .infer(from: url)
        else
        {
            fatalError("unimplemented")
        }

        let root:FilePath = self.path / package.description
        do
        {
            try await SystemProcess.init(command: "git", "-C", root.string, "fetch")()
        }
        catch SystemProcessError.exit
        {
            try await SystemProcess.init(command: "git", "-C", self.path.string,
                "clone", url, package.description)()
        }

        try await SystemProcess.init(command: "git", "-C", root.string,
            "checkout", reference)()

        let (readable, writable):(FileDescriptor, FileDescriptor) =
            try FileDescriptor.pipe()

        defer
        {
            try? writable.close()
            try? readable.close()
        }

        try await SystemProcess.init(command: "git", "-C", root.string,
            "rev-list", "-n", "1", reference,
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

        let reference:Repository.Reference = SemanticVersion.init(tag: reference).map(
            Repository.Reference.version(_:)) ?? .branch(reference)

        return .init(root: root, pin: .init(id: package,
            reference: reference,
            revision: revision,
            location: .remote(url: url)))
    }
}
