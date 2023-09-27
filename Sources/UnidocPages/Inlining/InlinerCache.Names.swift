import Unidoc
import UnidocRecords

extension InlinerCache
{
    struct Names:Sendable
    {
        let principal:Volume.Meta
        private(set)
        var secondary:[Unidoc.Zone: Volume.Meta]

        init(
            principal:Volume.Meta,
            secondary:[Unidoc.Zone: Volume.Meta] = [:])
        {
            self.principal = principal
            self.secondary = secondary
        }
    }
}
extension InlinerCache.Names
{
    mutating
    func add(_ names:[Volume.Meta])
    {
        for names:Volume.Meta in names where
            names.id != self.principal.id
        {
            self.secondary[names.id] = names
        }
    }
}
extension InlinerCache.Names
{
    subscript(zone:Unidoc.Zone) -> Volume.Meta?
    {
        self.principal.id == zone ? self.principal : self.secondary[zone]
    }
}
