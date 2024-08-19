import MD5
import UnidocRecords

extension Unidoc.Mesh
{
    @frozen public
    struct Boundary
    {
        public
        let targetABI:MD5?
        public
        let target:Unidoc.VolumeMetadata.Dependency

        init(targetABI:MD5?, target:Unidoc.VolumeMetadata.Dependency)
        {
            self.targetABI = targetABI
            self.target = target
        }
    }
}
