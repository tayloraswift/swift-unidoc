import HTML
import UnidocRecords

extension Volume.Meta
{
    struct Domain
    {
        private
        let volume:Volume.Meta

        init(_ volume:Volume.Meta)
        {
            self.volume = volume
        }
    }
}
extension Volume.Meta.Domain:HyperTextOutputStreamable
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
