extension GenericConstraint
{
    @frozen public
    enum TypeExpression:Hashable, Equatable
    {
        case nominal(TypeIdentifier)
        case complex(String)
    }
}
extension GenericConstraint.TypeExpression:Sendable where TypeIdentifier:Sendable
{
}
extension GenericConstraint.TypeExpression
{
    @inlinable public
    var nominal:TypeIdentifier?
    {
        switch self
        {
        case .nominal(let type):    return type
        case .complex:              return nil
        }
    }
    @inlinable public
    func map<T>(_ transform:(TypeIdentifier) throws -> T)
        rethrows -> GenericConstraint<T>.TypeExpression
    {
        switch self
        {
        case .nominal(let type):    return .nominal(try transform(type))
        case .complex(let type):    return .complex(type)
        }
    }
}
