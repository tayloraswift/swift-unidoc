import BSONEncoding
import Unidoc
import UnidocRecords

@frozen public
struct Records:Sendable
{
    public
    var latest:Unidoc.Zone?
    public
    var zone:Record.Zone

    public
    var masters:[Record.Master]
    public
    var groups:[Record.Group]

    @inlinable public
    init(zone:Record.Zone,
        masters:[Record.Master] = [],
        groups:[Record.Group] = [])
    {
        self.zone = zone

        if  case _? = self.zone.patch
        {
            self.latest = self.zone.id
        }
        else
        {
            self.latest = nil
        }

        self.masters = masters
        self.groups = groups
    }
}
extension Records
{
    @inlinable public
    func groups(latest:Bool) -> Groups<Bool>
    {
        .init(self.groups, latest: latest)
    }
}
