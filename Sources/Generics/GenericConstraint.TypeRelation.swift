extension GenericConstraint
{
    @frozen public
    enum TypeRelation:Hashable, Equatable
    {
        case conformer(of:TypeExpression)
        case subclass(of:TypeExpression)
        case type(TypeExpression)
    }
}
extension GenericConstraint.TypeRelation:Sendable where TypeReference:Sendable
{
}
extension GenericConstraint.TypeRelation
{
    @inlinable public
    var type:GenericConstraint<TypeReference>.TypeExpression
    {
        switch self
        {
        case .conformer(of: let type):  return type
        case .subclass(of: let type):   return type
        case .type(let type):           return type
        }
    }
    @inlinable public
    func map<T>(
        _ transform:(TypeReference) throws -> T) rethrows -> GenericConstraint<T>.TypeRelation
    {
        switch self
        {
        case .conformer(of: let type):  return .conformer(of: try type.map(transform))
        case .subclass(of: let type):   return .subclass(of: try type.map(transform))
        case .type(let type):           return .type(try type.map(transform))
        }
    }
}
