import Availability
import Generics

@frozen public
struct Declaration<Symbol>:Equatable where Symbol:Hashable
{
    public
    let availability:Availability
    public
    var abridged:Abridged
    public
    var expanded:Expanded
    public
    var generics:GenericSignature<Symbol>

    @inlinable public
    init(availability:Availability = .init(),
        abridged:Abridged = .init(),
        expanded:Expanded = .init(),
        generics:GenericSignature<Symbol> = .init())
    {
        self.availability = availability
        self.expanded = expanded
        self.abridged = abridged
        self.generics = generics
    }
}
extension Declaration:Sendable where Symbol:Sendable
{
}
extension Declaration
{
    @inlinable public
    func map<T>(_ transform:(Symbol) throws -> T) rethrows -> Declaration<T>
    {
        .init(availability: self.availability,
            abridged: .init(bytecode: self.abridged.bytecode),
            expanded: try self.expanded.map(transform),
            generics: try self.generics.map(transform))
    }
}
