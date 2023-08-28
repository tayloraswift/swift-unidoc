import Unidoc

@available(*, deprecated, renamed: "Volume")
public typealias Record = Volume

@frozen public
struct Volume
{
    public
    var latest:Unidoc.Zone?

    public
    var masters:[Volume.Master]
    public
    var groups:[Volume.Group]
    public
    var names:Volume.Names

    @inlinable public
    init(latest:Unidoc.Zone?,
        masters:[Volume.Master],
        groups:[Volume.Group],
        names:Volume.Names)
    {
        self.latest = latest

        self.masters = masters
        self.groups = groups
        self.names = names
    }
}
extension Volume:Identifiable
{
    @inlinable public
    var id:VolumeIdentifier { self.names.volume }
}
