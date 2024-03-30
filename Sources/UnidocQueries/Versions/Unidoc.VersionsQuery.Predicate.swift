import UnidocAPI

extension Unidoc.VersionsQuery
{
    @frozen public
    enum Predicate:Equatable, Hashable, Sendable
    {
        case tags(limit:Int, page:Int = 0, series:Unidoc.VersionSeries)
        case none(limit:Int)
    }
}
