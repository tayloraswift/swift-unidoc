@frozen public
struct TargetNode:Equatable, Hashable, Sendable
{
    public
    let name:String
    public
    let type:TargetType
    public
    let dependencies:ModuleDependencies
    /// The path to the module’s source directory, relative to the
    /// package root. If nil, the path is just [`"Sources/\(self.id)"`]().
    public
    let path:String?

    @inlinable public
    init(name:String,
        type:TargetType,
        dependencies:ModuleDependencies,
        path:String?)
    {
        self.name = name
        self.type = type
        self.dependencies = dependencies
        self.path = path
    }
}
extension TargetNode:Identifiable
{
    @inlinable public
    var id:ModuleIdentifier
    {
        .init(mangling: self.name)
    }
}
