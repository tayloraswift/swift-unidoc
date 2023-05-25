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
    /// package root. If nil, the path is just [`"Sources/\(self.name)"`]().
    public
    let location:String?

    /// Creates a target node.
    ///
    /// -   Parameters:
    ///     -   name:
    ///         The name of the target. (Not the name of the module!)
    ///
    ///     -   type:
    ///         The type of the target.
    ///
    ///     -   dependencies:
    ///         All of the targets included by this target, directly *or*
    ///         indirectly, except for itself.
    ///
    ///         This should also include the products depended-upon by this
    ///         target or any of its dependencies, but this set is not
    ///         deeply-explored since an upstream product’s own product
    ///         dependencies are controlled by the upstream package.
    ///
    ///     -   location:
    ///         The directory containing the target’s sources, if different
    ///         from `"/Sources/\(self.name)"`
    @inlinable public
    init(name:String,
        type:TargetType = .regular,
        dependencies:ModuleDependencies = .init(),
        location:String? = nil)
    {
        self.name = name
        self.type = type
        self.dependencies = dependencies
        self.location = location
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
