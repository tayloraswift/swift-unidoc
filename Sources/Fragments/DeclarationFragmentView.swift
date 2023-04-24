public
protocol DeclarationFragmentView:Sequence
{
    associatedtype Symbol:Hashable
    associatedtype Color:Hashable

    static
    subscript(_ overlay:DeclarationOverlay) -> Color? { get }

    var base:DeclarationFragments<Symbol> { get }
}
extension DeclarationFragmentView
{
    @inlinable public
    func makeIterator() -> DeclarationFragments<Symbol>.FilteringIterator<Self>
    {
        .init(base: self.base.fragments.makeIterator())
    }
}
