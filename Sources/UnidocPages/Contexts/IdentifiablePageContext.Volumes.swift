import Unidoc
import UnidocRecords

extension IdentifiablePageContext
{
    struct Volumes:Sendable
    {
        let principal:Volume.Meta
        private(set)
        var secondary:[Unidoc.Edition: Volume.Meta]

        init(
            principal:Volume.Meta,
            secondary:[Unidoc.Edition: Volume.Meta] = [:])
        {
            self.principal = principal
            self.secondary = secondary
        }
    }
}
extension IdentifiablePageContext.Volumes
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
extension IdentifiablePageContext.Volumes
{
    subscript(zone:Unidoc.Edition) -> Volume.Meta?
    {
        self.principal.id == zone ? self.principal : self.secondary[zone]
    }
}
