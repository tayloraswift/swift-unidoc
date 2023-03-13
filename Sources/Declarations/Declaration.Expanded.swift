extension Declaration
{
    @frozen public
    struct Expanded
    {
        public
        let base:Declaration<Symbol>

        @inlinable internal
        init(_ base:Declaration<Symbol>)
        {
            self.base = base
        }
    }
}
extension Declaration.Expanded:Sendable where Symbol:Sendable
{
}
extension Declaration.Expanded:DeclarationView
{
    @inlinable public static
    subscript(_ overlay:DeclarationOverlay) -> DeclarationFragmentClass??
    {
        switch overlay.elision
        {
        case nil, .never?, .abridged?:  return overlay.classification
        case .expanded?:                return nil
        }
    }
}
