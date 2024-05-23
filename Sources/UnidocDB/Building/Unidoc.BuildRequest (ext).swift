import UnidocAPI

extension Unidoc.BuildRequest
{
    @inlinable public
    var edition:Unidoc.Edition?
    {
        switch self
        {
        case .latest(_, force: _):  nil
        case .id(let edition, _):   edition
        }
    }

    @inlinable public
    var selector:Unidoc.BuildSelector
    {
        switch self
        {
        case .latest(let series, force: let force): .latest(series, force: force)
        case .id(_, force: let force):              .id(force: force)
        }
    }
}
