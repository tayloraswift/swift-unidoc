import UnidocRecords

extension DeepQuery
{
    @frozen public
    enum Planes:Equatable, Hashable, Sendable
    {
        case docs
        case learn
    }
}
extension DeepQuery.Planes
{
    var range:(min:Record.Zone.CodingKey, max:Record.Zone.CodingKey)
    {
        switch self
        {
        case .docs:     return (.planes_min,        .planes_extension)
        case .learn:    return (.planes_article,    .planes_max)
        }
    }
}
