import Unidoc
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct Volumes:Sendable
    {
        public
        let principal:Unidoc.VolumeMetadata
        public private(set)
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
extension Unidoc.Volumes
{
    public
    init(principal:Unidoc.VolumeMetadata, secondary:borrowing [Unidoc.VolumeMetadata] = [])
    {
        let secondary:[Unidoc.Edition: Unidoc.VolumeMetadata] = secondary.reduce(into: [:])
        {
            $0[$1.id] = principal.id != $1.id ? $1 : nil
        }
        self.init(principal: principal, secondary: secondary)
    }
}
extension Unidoc.Volumes
{
    @inlinable public
    subscript(zone:Unidoc.Edition) -> Unidoc.VolumeMetadata?
    {
        self.principal.id == zone ? self.principal : self.secondary[zone]
    }
}
