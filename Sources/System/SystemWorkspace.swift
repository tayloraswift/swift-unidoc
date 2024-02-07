public
protocol SystemWorkspace:CustomStringConvertible
{
    init(path:FilePath)
    var path:FilePath { get }
}
extension SystemWorkspace
{
    @inlinable public
    var description:String { "\(self.path)" }
}
extension SystemWorkspace
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
extension SystemWorkspace
{
    /// Creates a nested workspace directory within this one.
    public
    func create<NestedWorkspace>(_ name:String,
        clean:Bool = false,
        as  _:NestedWorkspace.Type = Self.self) async throws -> NestedWorkspace
        where NestedWorkspace:SystemWorkspace
    {
        let workspace:NestedWorkspace = try await .create(at: self.path / name)
        if  clean
        {
            try await workspace.clean()
        }
        return workspace
    }
}
