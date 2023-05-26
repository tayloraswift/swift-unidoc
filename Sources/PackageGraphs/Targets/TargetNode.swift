import ModuleGraphs

@frozen public
struct TargetNode:Equatable, Sendable
{
    public
    let name:String
    public
    let type:ModuleType
    public
    let dependencies:Dependencies
    /// Paths of excluded files, relative to the target source directory.
    public
    let exclude:[String]
    /// The path to the target’s source directory, relative to the
    /// package root. If nil, the path is just [`"Sources/\(self.id)"`]().
    public
    let path:String?

    @inlinable public
    init(name:String, type:ModuleType = .regular,
        dependencies:Dependencies = .init(),
        exclude:[String] = [],
        path:String? = nil)
    {
        self.name = name
        self.type = type
        self.dependencies = dependencies
        self.exclude = exclude
        self.path = path
    }
}
extension TargetNode:Identifiable
{
    /// Same as ``name``.
    @inlinable public
    var id:String { self.name }
}
extension TargetNode:DigraphNode
{
    /// Same as `dependencies.targets`.
    @inlinable public
    var predecessors:[Dependency<String>] { self.dependencies.targets }
}
