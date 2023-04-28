import Codelinks

extension SymbolGraph
{
    @frozen public
    enum Referent:Equatable, Hashable, Sendable
    {
        case unresolved(Codelink)

        case scalar(ScalarAddress)
        case vector(ScalarAddress, self:ScalarAddress)
    }
}
