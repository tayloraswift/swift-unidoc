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
    public
    var names:Volume.Meta

    @inlinable public
    init(latest:Unidoc.Zone?,
        vertices:[Volume.Vertex],
        groups:[Volume.Group],
        names:Volume.Meta)
    {
        self.latest = latest

        self.vertices = vertices
        self.groups = groups
        self.names = names
    }
}
extension Volume
{
    @inlinable public
    var edition:Unidoc.Zone { self.names.id }
}
extension Volume:Identifiable
{
    @inlinable public
    var id:VolumeIdentifier { self.names.volume }
}
