@frozen public
struct ProductDetails:Equatable, Hashable, Sendable
{
    public
    let name:String
    public
    let type:ProductType
    public
    var dependencies:[ProductIdentifier]
    public
    var cultures:[Int]

    @inlinable public
    init(name:String, type:ProductType, dependencies:[ProductIdentifier], cultures:[Int])
    {
        self.name = name
        self.type = type
        self.dependencies = dependencies
        self.cultures = cultures
    }
}
