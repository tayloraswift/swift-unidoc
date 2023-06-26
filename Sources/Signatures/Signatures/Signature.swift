import Availability

@frozen public
struct Signature<Scalar>:Equatable where Scalar:Hashable
{
    public
    var availability:Availability
    public
    var abridged:Abridged
    public
    var expanded:Expanded
    public
    var generics:Generics

    @inlinable public
    init(availability:Availability = .init(),
        abridged:Abridged = .init(),
        expanded:Expanded = .init(),
        generics:Generics = .init())
    {
        self.availability = availability
        self.expanded = expanded
        self.abridged = abridged
        self.generics = generics
    }
}
extension Signature:Sendable where Scalar:Sendable
{
}
extension Signature
{
    @inlinable public
    func map<T>(_ transform:(Scalar) throws -> T) rethrows -> Signature<T>
    {
        .init(availability: self.availability,
            abridged: .init(bytecode: self.abridged.bytecode),
            expanded: try self.expanded.map(transform),
            generics: try self.generics.map(transform))
    }
}
