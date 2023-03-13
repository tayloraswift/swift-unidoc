extension Declaration
{
    @frozen public
    struct FragmentIterator<View> where View:DeclarationView
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
extension Declaration.FragmentIterator:IteratorProtocol
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
