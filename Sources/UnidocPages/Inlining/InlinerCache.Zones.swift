import Unidoc
import UnidocRecords

extension InlinerCache
{
    struct Zones:Sendable
    {
        let principal:Record.Zone
        private(set)
        var secondary:[Unidoc.Zone: Record.Zone]

        init(
            principal:Record.Zone,
            secondary:[Unidoc.Zone: Record.Zone] = [:])
        {
            self.principal = principal
            self.secondary = secondary
        }
    }
}
extension InlinerCache.Zones
{
    mutating
    func add(_ zones:[Record.Zone])
    {
        for zone:Record.Zone in zones where
            zone.id != self.principal.id
        {
            self.secondary[zone.id] = zone
        }
    }
}
extension InlinerCache.Zones
{
    subscript(zone:Unidoc.Zone) -> Record.Zone?
    {
        self.principal.id == zone ? self.principal : self.secondary[zone]
    }
}
