extension DeclarationFragments
{
    @frozen public
    struct Identifiers
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
extension DeclarationFragments.Identifiers:Sendable where Symbol:Sendable
{
}
extension DeclarationFragments.Identifiers:DeclarationFragmentView
{
    @inlinable public static
    subscript(_ overlay:DeclarationOverlay) -> Never??
    {
        switch overlay.elision
        {
        case .never?:                       return (nil as Never?)
        case nil, .abridged?, .expanded?:   return  nil
        }
    }
}
