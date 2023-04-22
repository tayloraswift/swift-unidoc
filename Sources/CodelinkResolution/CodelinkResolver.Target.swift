import SymbolGraphs

extension CodelinkResolver
{
    @frozen public
    enum Target:Equatable, Hashable, Sendable
    {
        case scalar     (ScalarAddress)
        case compound   (ScalarAddress, self:ScalarAddress)
    }
}
