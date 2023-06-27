@frozen public
enum GenericConstraint<Scalar>:Equatable, Hashable where Scalar:Hashable
{
    case `where`(_ noun:String, is:GenericOperator, to:GenericType<Scalar>)
}
extension GenericConstraint
{
    @inlinable public
    var noun:String
    {
        switch self { case .where(let noun, is: _, to: _): return noun }
    }
    @inlinable public
    var what:GenericOperator
    {
        switch self { case .where(_, is: let what, to: _): return what }
    }
    @inlinable public
    var whom:GenericType<Scalar>
    {
        switch self { case .where(_, is: _, to: let whom): return whom }
    }
}
extension GenericConstraint:Comparable where Scalar:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (lhs.noun, lhs.what, lhs.whom) < (rhs.noun, rhs.what, rhs.whom)
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
        .where(self.noun, is: self.what, to: try self.whom.map(transform))
    }
    @inlinable public
    func flatMap<T>(_ transform:(Scalar) throws -> T?) rethrows -> GenericConstraint<T>?
    {
        try self.whom.flatMap(transform).map { .where(self.noun, is: self.what, to: $0) }
    }
}
