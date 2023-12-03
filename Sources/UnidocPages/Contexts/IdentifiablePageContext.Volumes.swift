import Unidoc
import UnidocRecords

extension IdentifiablePageContext
{
    struct Volumes:Sendable
    {
        let principal:Volume.Metadata
        private(set)
        var secondary:[Unidoc.Edition: Volume.Metadata]

        init(
            principal:Volume.Metadata,
            secondary:[Unidoc.Edition: Volume.Metadata] = [:])
        {
            self.principal = principal
            self.secondary = secondary
        }
    }
}
extension IdentifiablePageContext.Volumes
{
    mutating
    func add(_ names:[Volume.Metadata])
    {
        for names:Volume.Metadata in names where
            names.id != self.principal.id
        {
            self.secondary[names.id] = names
        }
    }
}
extension IdentifiablePageContext.Volumes
{
    subscript(zone:Unidoc.Edition) -> Volume.Metadata?
    {
        self.principal.id == zone ? self.principal : self.secondary[zone]
    }
}
