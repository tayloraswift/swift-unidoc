import Unidoc

@available(*, deprecated, renamed: "Volume")
public typealias Record = Volume

@frozen public
struct Volume
{
    public
    var latest:Unidoc.Zone?

    public
    var vertices:[Volume.Vertex]
    public
    var groups:[Volume.Group]

    @available(*, deprecated, renamed: "meta")
    public
    var names:Volume.Meta { self.meta }

    public
    var meta:Volume.Meta

    @inlinable public
    init(latest:Unidoc.Zone?,
        vertices:[Volume.Vertex],
        groups:[Volume.Group],
        meta:Volume.Meta)
    {
        self.latest = latest

        self.vertices = vertices
        self.groups = groups
        self.meta = meta
    }
}
extension Volume
{
    @inlinable public
    var edition:Unidoc.Zone { self.meta.id }
}
extension Volume:Identifiable
{
    @inlinable public
    var id:VolumeIdentifier { self.meta.symbol }
}
