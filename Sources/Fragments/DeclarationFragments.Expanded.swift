extension DeclarationFragments
{
    @frozen public
    struct Expanded
    {
        public
        let base:DeclarationFragments<Symbol>

        @inlinable internal
        init(_ base:DeclarationFragments<Symbol>)
        {
            self.base = base
        }
    }
}
extension DeclarationFragments.Expanded:Sendable where Symbol:Sendable
{
}
extension DeclarationFragments.Expanded:DeclarationFragmentView
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
