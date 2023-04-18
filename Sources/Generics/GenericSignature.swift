@frozen public
struct GenericSignature<TypeReference>:Equatable, Hashable where TypeReference:Hashable
{
    public
    var constraints:[GenericConstraint<TypeReference>]
    /// All of the relevant symbol’s type parameters, including
    /// type parameters inherited from the enclosing scope, and
    /// type parameters shadowed by other type parameters.
    public
    var parameters:[GenericParameter]

    @inlinable public
    init(constraints:[GenericConstraint<TypeReference>] = [],
        parameters:[GenericParameter] = [])
    {
        self.constraints = constraints
        self.parameters = parameters
    }
}
extension GenericSignature:Sendable where TypeReference:Sendable
{
}
extension GenericSignature
{
    @inlinable public
    func map<T>(_ transform:(TypeReference) throws -> T) rethrows -> GenericSignature<T>
    {
        .init(constraints: try self.constraints.map { try $0.map(transform) },
            parameters: self.parameters)
    }
}
