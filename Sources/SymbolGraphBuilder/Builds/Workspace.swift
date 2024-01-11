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
extension Workspace:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "\(self.path)"
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
        if  clean
        {
            try await workspace.clean()
        }
        return workspace
    }
}
