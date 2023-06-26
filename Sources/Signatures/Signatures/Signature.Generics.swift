extension Signature
{
    @frozen public
    struct Generics:Equatable, Hashable
    {
        public
        var constraints:[GenericConstraint<Scalar>]
        /// All of the relevant symbol’s type parameters, including
        /// type parameters inherited from the enclosing scope, and
        /// type parameters shadowed by other type parameters.
        public
        var parameters:[GenericParameter]

        @inlinable public
        init(constraints:[GenericConstraint<Scalar>] = [],
            parameters:[GenericParameter] = [])
        {
            self.constraints = constraints
            self.parameters = parameters
        }
    }
}
extension Signature.Generics:Sendable where Scalar:Sendable
{
}
extension Signature.Generics
{
    @inlinable public
    func map<T>(_ transform:(Scalar) throws -> T) rethrows -> Signature<T>.Generics
    {
        .init(constraints: try self.constraints.map { try $0.map(transform) },
            parameters: self.parameters)
    }
}
