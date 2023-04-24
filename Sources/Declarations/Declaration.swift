import Availability
import Fragments
import Generics

@frozen public
struct Declaration<Symbol>:Equatable where Symbol:Hashable
{
    public
    let availability:Availability
    public
    var fragments:DeclarationFragments<Symbol>
    public
    var generics:GenericSignature<Symbol>

    @inlinable public
    init(availability:Availability = .init(),
        fragments:DeclarationFragments<Symbol> = .init(),
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
