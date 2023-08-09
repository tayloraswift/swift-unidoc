import BSONEncoding
import SemanticVersions
import Unidoc
import UnidocRecords

extension Database
{
    struct Records
    {
        var latest:Unidoc.Zone?

        var masters:[Record.Master]
        var groups:[Record.Group]
        var zone:Record.Zone

        private
        init(latest:Unidoc.Zone?,
            masters:[Record.Master],
            groups:[Record.Group],
            zone:Record.Zone)
        {
            self.latest = latest

            self.masters = masters
            self.groups = groups
            self.zone = zone
        }
    }
}
extension Database.Records
{
    init(latest:Database.Zones.PatchView?,
        masters:[Record.Master],
        groups:[Record.Group],
        zone:Record.Zone)
    {
        self.init(latest: latest?.id,
            masters: masters,
            groups: groups,
            zone: zone)

        guard let patch:PatchVersion = self.zone.patch
        else
        {
            self.zone.latest = false
            return
        }

        if  let latest:PatchVersion = latest?.patch,
                latest > patch
        {
            self.zone.latest = false
        }
        else
        {
            self.zone.latest = true
            self.latest = self.zone.id
        }
    }
}
extension Database.Records
{
    @inlinable public
    func groups(latest:Bool) -> Groups<Bool>
    {
        .init(self.groups, latest: latest)
    }
}
