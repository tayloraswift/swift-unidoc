import UnidocAPI

extension Unidoc
{
    @frozen public
    enum BuildRequest:Equatable, Sendable
    {
        case latest(VersionSeries, force:Bool)
        case id(Edition)
    }
}
extension Unidoc.BuildRequest
{
    @inlinable public
    var edition:Unidoc.Edition?
    {
        switch self
        {
        case .latest(_, force: _):  nil
        case .id(let edition):      edition
        }
    }

    @inlinable public
    var selector:Unidoc.BuildSelector
    {
        switch self
        {
        case .latest(let series, force: let force): .latest(series, force: force)
        case .id:                                   .id
        }
    }
}
