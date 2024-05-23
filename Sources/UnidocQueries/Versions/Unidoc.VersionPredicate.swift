import UnidocAPI

extension Unidoc
{
    @frozen public
    enum VersionPredicate:Sendable
    {
        case latest(VersionSeries)
        case name(String)
    }
}
