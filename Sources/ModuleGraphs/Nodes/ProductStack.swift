@frozen public
struct ProductStack:Equatable, Hashable, Sendable
{
    public
    let name:String
    public
    let type:ProductType
    public
    var dependencies:ModuleDependencies

    @inlinable public
    init(name:String, type:ProductType, dependencies:ModuleDependencies)
    {
        self.name = name
        self.type = type
        self.dependencies = dependencies
    }
}
