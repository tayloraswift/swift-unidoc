import Availability
import Generics

@frozen public
struct Declaration<Symbol>:Equatable where Symbol:Hashable
{
    public
    let availability:Availability
    public
    var fragments:Fragments
    public
    var generics:GenericSignature<Symbol>

    @inlinable public
    init(availability:Availability = .init(),
        fragments:Fragments = .init(),
        generics:GenericSignature<Symbol> = .init())
    {
        self.availability = availability
        self.fragments = fragments
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
            fragments: try self.fragments.map(transform),
            generics: try self.generics.map(transform))
    }
}
