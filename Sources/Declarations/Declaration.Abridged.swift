extension Declaration
{
    @frozen public
    struct Abridged
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
extension Declaration.Abridged:Sendable where Symbol:Sendable
{
}
extension Declaration.Abridged:DeclarationView
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
