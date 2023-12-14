import HTML
import UnidocRecords

extension Unidoc.VolumeMetadata
{
    struct Domain
    {
        private
        let volume:Unidoc.VolumeMetadata

        init(_ volume:Unidoc.VolumeMetadata)
        {
            self.volume = volume
        }
    }
}
extension Unidoc.VolumeMetadata.Domain:HyperTextOutputStreamable
{
    static
    func += (span:inout HTML.ContentEncoder, self:Self)
    {
        span[.span, { $0.class = "volume" }]
        {
            $0[.a]
            {
                $0.href = "\(Site.Docs[self.volume])"
            } = "\(self.volume.symbol.package) \(self.volume.symbol.version)"
        }

        span[.span, { $0.class = "jump" }]
        {
            $0[.a]
            {
                $0.href = "\(Site.Tags[self.volume.symbol.package])"
            } = "all tags"
        }
    }
}
