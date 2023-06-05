@frozen public
struct ModuleDetails:Equatable, Hashable, Sendable
{
    /// The *unmangled* name of the module. (Not the module’s ``id``!)
    public
    let name:String
    /// The type of the module.
    public
    let type:ModuleType
    public
    let dependencies:ModuleDependencies
    /// The path to the module’s source directory, relative to the
    /// package root. If nil, the path is just [`"Sources/\(self.name)"`]().
    public
    let location:String?

    @inlinable public
    init(name:String,
        type:ModuleType = .regular,
        dependencies:ModuleDependencies = .init(),
        location:String? = nil)
    {
        self.name = name
        self.type = type
        self.dependencies = dependencies
        self.location = location
    }
}
extension ModuleDetails:Identifiable
{
    /// The mangled name of the module.
    @inlinable public
    var id:ModuleIdentifier
    {
        .init(mangling: self.name)
    }
}
