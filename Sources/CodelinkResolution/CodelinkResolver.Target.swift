import SymbolGraphs

extension CodelinkResolver
{
    @frozen public
    enum Target:Equatable, Hashable, Sendable
    {
        case scalar(ScalarAddress)
        case vector(ScalarAddress, self:ScalarAddress)
    }
}
