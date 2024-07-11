import UnidocAPI

extension Unidoc.BuildRequest
{
    @inlinable public
    var behavior:Unidoc.BuildBehavior
    {
        switch self.version
        {
        case .latest(let series, of: _):    .latest(series, force: self.rebuild)
        case .id:                           .id(force: self.rebuild)
        }
    }
}
