import UnidocRecords

extension Selector
{
    @frozen public
    enum Planes:Equatable, Hashable, Sendable
    {
        /// Matches the ``UnidocPlane module`` and ``UnidocPlane decl`` planes.
        case docs

        /// Matches the ``UnidocPlane article`` plane only.
        case article
        /// Matches the ``UnidocPlane file`` plane only.
        case file
    }
}
extension Selector.Planes
{
    @inlinable public
    var range:(min:Record.Zone.CodingKey, max:Record.Zone.CodingKey)
    {
        switch self
        {
        case .docs:     return (.planes_min,        .planes_article)

        case .article:  return (.planes_article,    .planes_file)
        case .file:     return (.planes_file,       .planes_extension)
        }
    }
}
