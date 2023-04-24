extension DeclarationFragments
{
    @frozen public
    struct FilteringIterator<View> where View:DeclarationFragmentView
    {
        @usableFromInline internal
        var base:IndexingIterator<[DeclarationFragment<Symbol, DeclarationOverlay>]>

        @inlinable internal
        init(base:IndexingIterator<[DeclarationFragment<Symbol, DeclarationOverlay>]>)
        {
            self.base = base
        }
    }
}
extension DeclarationFragments.FilteringIterator:IteratorProtocol
{
    @inlinable public mutating
    func next() -> DeclarationFragment<Symbol, View.Color>?
    {
        while let fragment:DeclarationFragment<Symbol, DeclarationOverlay> = self.base.next()
        {
            if let color:View.Color = View[fragment.color]
            {
                return fragment.with(color: color)
            }
        }
        return nil
    }
}
