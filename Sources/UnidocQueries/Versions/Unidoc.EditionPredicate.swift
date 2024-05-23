import UnidocAPI

extension Unidoc
{
    @frozen public
    enum EditionPredicate:Sendable
    {
        case latest(VersionSeries)
        case name(String)
    }
}
