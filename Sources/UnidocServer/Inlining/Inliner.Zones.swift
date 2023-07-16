import Unidoc
import UnidocRecords

extension Inliner
{
    struct Zones:Sendable
    {
        let principal:(id:Unidoc.Zone, zone:Record.Zone.Names)
        private(set)
        var secondary:[Unidoc.Zone: Record.Zone.Names]

        init(
            principal:(id:Unidoc.Zone, zone:Record.Zone.Names),
            secondary:[Unidoc.Zone: Record.Zone.Names] = [:])
        {
            self.principal = principal
            self.secondary = secondary
        }
    }
}
extension Inliner.Zones
{
    mutating
    func add(_ zones:[Record.Zone])
    {
        for zone:Record.Zone in zones where
            zone.id != self.principal.id
        {
            self.secondary[zone.id] = zone.names
        }
    }
}
extension Inliner.Zones
{
    subscript(_ zone:Unidoc.Zone) -> Record.Zone.Names?
    {
        self.principal.id == zone ? self.principal.zone : self.secondary[zone]
    }
}
