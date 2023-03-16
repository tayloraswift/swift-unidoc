@frozen public
struct GenericContext<TypeReference> where TypeReference:Hashable
{
    public
    var parameters:[GenericParameter]
    public
    var constraints:[GenericConstraint<TypeReference>]

    @inlinable public
    init(_ parameters:[GenericParameter] = [],
        constraints:[GenericConstraint<TypeReference>] = [])
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
extension GenericContext:Equatable where TypeReference:Equatable
{
}
extension GenericContext:Hashable where TypeReference:Hashable
{
}
extension GenericContext:Sendable where TypeReference:Sendable
{
}
extension GenericContext
{
    @inlinable public
    func map<T>(
        _ transform:(TypeReference) throws -> T) rethrows -> GenericContext<T>
    {
        .init(self.parameters, constraints: try self.constraints.map{ try $0.map(transform) })
    }
}
