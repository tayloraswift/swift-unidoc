import Unidoc
import UnidocRecords

extension InlinerCache
{
    struct Names:Sendable
    {
        let principal:Volume.Names
        private(set)
        var secondary:[Unidoc.Zone: Volume.Names]

        init(
            principal:Volume.Names,
            secondary:[Unidoc.Zone: Volume.Names] = [:])
        {
            self.principal = principal
            self.secondary = secondary
        }
    }
}
extension InlinerCache.Names
{
    mutating
    func add(_ names:[Volume.Names])
    {
        for names:Volume.Names in names where
            names.id != self.principal.id
        {
            self.secondary[names.id] = names
        }
    }
}
extension InlinerCache.Names
{
    subscript(zone:Unidoc.Zone) -> Volume.Names?
    {
        self.principal.id == zone ? self.principal : self.secondary[zone]
    }
}
