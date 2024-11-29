import MD5
import UnidocRecords

extension Unidoc.Mesh
{
    @frozen public
    struct Boundary
    {
        public
        let targetRef:String?
        public
        let targetABI:MD5?
        public
        let target:Unidoc.VolumeMetadata.Dependency

        @inlinable public
        init(targetRef:String?, targetABI:MD5?, target:Unidoc.VolumeMetadata.Dependency)
        {
            self.targetRef = targetRef
            self.targetABI = targetABI
            self.target = target
        }
    }
}
