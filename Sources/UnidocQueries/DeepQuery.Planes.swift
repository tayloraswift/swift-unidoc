import UnidocRecords

extension DeepQuery
{
    @frozen public
    enum Planes:Equatable, Hashable, Sendable
    {
        /// Matches the ``UnidocPlane article`` plane only.
        case article
        /// Matches all master planes except for the ``UnidocPlane article`` plane.
        case docs
    }
}
extension DeepQuery.Planes
{
    @inlinable public
    var range:(min:Record.Zone.CodingKey, max:Record.Zone.CodingKey)
    {
        switch self
        {
        case .article:  return (.planes_article,    .planes_extension)
        case .docs:     return (.planes_min,        .planes_article)
        }
    }
}
