@frozen public
struct GenericContext<TypeIdentifier> where TypeIdentifier:Hashable
{
    public
    var parameters:[GenericParameter]
    public
    var constraints:[GenericConstraint<TypeIdentifier>]

    @inlinable public
    init(_ parameters:[GenericParameter] = [],
        constraints:[GenericConstraint<TypeIdentifier>] = [])
    {
        self.parameters = parameters
        self.constraints = constraints
    }
}
extension GenericContext
{
    @inlinable public
    var isEmpty:Bool
    {
        self.parameters.isEmpty && self.constraints.isEmpty
    }
}
extension GenericContext:Equatable where TypeIdentifier:Equatable
{
}
extension GenericContext:Hashable where TypeIdentifier:Hashable
{
}
extension GenericContext:Sendable where TypeIdentifier:Sendable
{
}
extension GenericContext
{
    @inlinable public
    func map<T>(
        _ transform:(TypeIdentifier) throws -> T) rethrows -> GenericContext<T>
    {
        .init(self.parameters, constraints: try self.constraints.map{ try $0.map(transform) })
    }
}
