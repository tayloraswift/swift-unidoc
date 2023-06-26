extension GenericConstraint
{
    @frozen public
    enum TypeExpression:Hashable, Equatable
    {
        case nominal(Scalar)
        case complex(String)
    }
}
extension GenericConstraint.TypeExpression:Comparable where Scalar:Comparable
{
}
extension GenericConstraint.TypeExpression:Sendable where Scalar:Sendable
{
}
extension GenericConstraint.TypeExpression
{
    @inlinable public
    var nominal:Scalar?
    {
        switch self
        {
        case .nominal(let type):    return type
        case .complex:              return nil
        }
    }
    @inlinable public
    func map<T>(
        _ transform:(Scalar) throws -> T) rethrows -> GenericConstraint<T>.TypeExpression
    {
        switch self
        {
        case .nominal(let type):    return .nominal(try transform(type))
        case .complex(let type):    return .complex(type)
        }
    }
}
