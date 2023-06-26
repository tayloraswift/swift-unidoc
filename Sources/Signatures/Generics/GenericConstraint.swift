@frozen public
struct GenericConstraint<Scalar>:Equatable, Hashable where Scalar:Hashable
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
extension GenericConstraint:Comparable where Scalar:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (lhs.name, lhs.is) < (rhs.name, rhs.is)
    }
}
extension GenericConstraint:Sendable where Scalar:Sendable
{
}
extension GenericConstraint
{
    @inlinable public
    func map<T>(_ transform:(Scalar) throws -> T) rethrows -> GenericConstraint<T>
    {
        .init(self.name, is: try self.is.map(transform))
    }
}
