@frozen public
struct GenericConstraint<TypeIdentifier> where TypeIdentifier:Hashable
{
    public
    let name:String
    public
    let `is`:TypeRelation

    @inlinable public
    init(_ name:String, is type:TypeRelation)
    {
        self.name = name
        self.is = type
    }
}
extension GenericConstraint:Equatable where TypeIdentifier:Equatable
{
}
extension GenericConstraint:Hashable where TypeIdentifier:Hashable
{
}
extension GenericConstraint:Sendable where TypeIdentifier:Sendable
{
}
extension GenericConstraint
{
    @inlinable public
    func map<T>(
        _ transform:(TypeIdentifier) throws -> T) rethrows -> GenericConstraint<T>
    {
        .init(self.name, is: try self.is.map(transform))
    }
}
