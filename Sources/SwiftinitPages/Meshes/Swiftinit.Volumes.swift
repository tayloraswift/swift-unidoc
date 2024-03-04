import Unidoc
import UnidocRecords

extension Swiftinit
{
    struct Volumes:Sendable
    {
        let principal:Unidoc.VolumeMetadata
        private(set)
        var secondary:[Unidoc.Edition: Unidoc.VolumeMetadata]

        private
        init(
            principal:Unidoc.VolumeMetadata,
            secondary:[Unidoc.Edition: Unidoc.VolumeMetadata])
        {
            self.principal = principal
            self.secondary = secondary
        }
    }
}
extension Swiftinit.Volumes
{
    init(principal:Unidoc.VolumeMetadata, secondary:[Unidoc.VolumeMetadata] = [])
    {
        let secondary:[Unidoc.Edition: Unidoc.VolumeMetadata] = secondary.reduce(into: [:])
        {
            $0[$1.id] = principal.id != $1.id ? $1 : nil
        }
        self.init(principal: principal, secondary: secondary)
    }
}
extension Swiftinit.Volumes
{
    subscript(zone:Unidoc.Edition) -> Unidoc.VolumeMetadata?
    {
        self.principal.id == zone ? self.principal : self.secondary[zone]
    }
}
