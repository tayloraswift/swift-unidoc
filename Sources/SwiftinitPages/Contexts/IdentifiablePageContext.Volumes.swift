import Unidoc
import UnidocRecords

extension IdentifiablePageContext
{
    struct Volumes:Sendable
    {
        let principal:Unidoc.VolumeMetadata
        private(set)
        var secondary:[Unidoc.Edition: Unidoc.VolumeMetadata]

        init(
            principal:Unidoc.VolumeMetadata,
            secondary:[Unidoc.Edition: Unidoc.VolumeMetadata] = [:])
        {
            self.principal = principal
            self.secondary = secondary
        }
    }
}
extension IdentifiablePageContext.Volumes
{
    mutating
    func add(_ names:[Unidoc.VolumeMetadata])
    {
        for names:Unidoc.VolumeMetadata in names where
            names.id != self.principal.id
        {
            self.secondary[names.id] = names
        }
    }
}
extension IdentifiablePageContext.Volumes
{
    subscript(zone:Unidoc.Edition) -> Unidoc.VolumeMetadata?
    {
        self.principal.id == zone ? self.principal : self.secondary[zone]
    }
}
