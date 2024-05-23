extension Unidoc
{
    @frozen public
    enum BuildRequest:Equatable, Sendable
    {
        case latest(VersionSeries, force:Bool)
        case id(Edition, force:Bool)
    }
}
