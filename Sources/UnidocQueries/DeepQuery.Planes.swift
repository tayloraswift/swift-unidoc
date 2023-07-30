import UnidocRecords

extension DeepQuery
{
    @frozen public
    enum Planes:Equatable, Hashable, Sendable
    {
        /// Matches all master planes except for the ``UnidocPlane article`` plane.
        case docs
        /// Matches the ``UnidocPlane article`` plane only.
        case learn
    }
}
extension DeepQuery.Planes
{
    @inlinable public
    var range:(min:Record.Zone.CodingKey, max:Record.Zone.CodingKey)
    {
        switch self
        {
        case .docs:     return (.planes_min,        .planes_article)
        case .learn:    return (.planes_article,    .planes_extension)
        }
    }
}
