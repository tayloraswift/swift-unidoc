public
protocol DeclarationView:Sequence
{
    associatedtype Symbol:Hashable
    associatedtype Color:Hashable

    static
    subscript(_ overlay:DeclarationOverlay) -> Color? { get }

    var base:Declaration<Symbol> { get }
}
extension DeclarationView
{
    @inlinable public
    func makeIterator() -> Declaration<Symbol>.FragmentIterator<Self>
    {
        .init(base: self.base.fragments.makeIterator())
    }
}
