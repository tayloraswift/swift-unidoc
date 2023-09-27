import Unidoc
import UnidocRecords

extension InlinerCache
{
    struct Volumes:Sendable
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
extension InlinerCache.Volumes
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
extension InlinerCache.Volumes
{
    subscript(zone:Unidoc.Zone) -> Volume.Meta?
    {
        self.principal.id == zone ? self.principal : self.secondary[zone]
    }
}
