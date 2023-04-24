extension DeclarationFragments
{
    @frozen public
    struct Abridged
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
extension DeclarationFragments.Abridged:Sendable where Symbol:Sendable
{
}
extension DeclarationFragments.Abridged:DeclarationFragmentView
{
    @inlinable public static
    subscript(_ overlay:DeclarationOverlay) -> Bool?
    {
        switch overlay.elision
        {
        case nil:           return false
        case .never?:       return true
        case .abridged?:    return nil
        case .expanded?:    return false
        }
    }
}
