@frozen public
struct ModuleDependencies:Equatable, Hashable, Sendable
{
    public
    var products:[ProductIdentifier]
    public
    var modules:[Int]

    @inlinable public
    init(products:[ProductIdentifier] = [], modules:[Int])
    {
        self.products = products
        self.modules = modules
    }
}
