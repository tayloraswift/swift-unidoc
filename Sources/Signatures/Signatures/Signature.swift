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

    /// Empty array means the declaration is gated by an SPI, but SymbolGraphGen doesn't know
    /// which one.
    public
    var spis:[String]?

    @inlinable public
    init(availability:Availability = .init(),
        abridged:Abridged = .init(),
        expanded:Expanded = .init(),
        generics:Generics = .init(),
        spis:[String]? = nil)
    {
        self.availability = availability
        self.expanded = expanded
        self.abridged = abridged
        self.generics = generics
        self.spis = spis
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
            generics: try self.generics.map(transform),
            spis: self.spis)
    }
}
