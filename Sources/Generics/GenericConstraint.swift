@frozen public
struct GenericConstraint<TypeReference>:Equatable, Hashable where TypeReference:Hashable
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
extension GenericConstraint:Sendable where TypeReference:Sendable
{
}
extension GenericConstraint
{
    @inlinable public
    func map<T>(
        _ transform:(TypeReference) throws -> T) rethrows -> GenericConstraint<T>
    {
        .init(self.name, is: try self.is.map(transform))
    }
}
