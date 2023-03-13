extension Declaration
{
    @frozen public
    struct Identifiers
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
extension Declaration.Identifiers:Sendable where Symbol:Sendable
{
}
extension Declaration.Identifiers:DeclarationView
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
