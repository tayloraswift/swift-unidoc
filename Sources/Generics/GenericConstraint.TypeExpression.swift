extension GenericConstraint
{
    @frozen public
    enum TypeExpression:Hashable, Equatable
    {
        case nominal(TypeReference)
        case complex(String)
    }
}
extension GenericConstraint.TypeExpression:Comparable where TypeReference:Comparable
{
}
extension GenericConstraint.TypeExpression:Sendable where TypeReference:Sendable
{
}
extension GenericConstraint.TypeExpression
{
    @inlinable public
    var nominal:TypeReference?
    {
        switch self
        {
        case .nominal(let type):    return type
        case .complex:              return nil
        }
    }
    @inlinable public
    func map<T>(_ transform:(TypeReference) throws -> T)
        rethrows -> GenericConstraint<T>.TypeExpression
    {
        switch self
        {
        case .nominal(let type):    return .nominal(try transform(type))
        case .complex(let type):    return .complex(type)
        }
    }
}
