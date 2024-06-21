import HTML
import UnidocRecords

extension Unidoc
{
    struct VertexDomain
    {
        private
        let volume:Unidoc.VolumeMetadata

        private
        let module:Module?
        private
        let colony:Module?

        init(volume:Unidoc.VolumeMetadata,
            module:Module? = nil,
            colony:Module? = nil)
        {
            self.volume = volume
            self.module = module
            self.colony = colony
        }
    }
}
extension Unidoc.VertexDomain:HTML.OutputStreamable
{
    static
    func += (span:inout HTML.ContentEncoder, self:Self)
    {
        span[.span, { $0.class = "volume" }]
        {
            $0[.a]
            {
                $0.href = "\(Unidoc.DocsEndpoint[self.volume])"
            } = "\(self.volume.symbol.package) \(self.volume.symbol.version)"
        }

        span[.span, { $0.class = "jump" }]
        {
            if  let module:Module = self.module
            {
                $0[.span] { $0.class = "culture" } = module

                guard
                let colony:Module = self.colony
                else
                {
                    return
                }

                $0[.span]
                {
                    $0.class = "extends"
                    $0.title = """
                    \(module.name), the current module, extends a type defined in \
                    \(colony.name), a different module.
                    """
                } = "->"
                $0[.span] { $0.class = "namespace" } = colony
            }
            else
            {
                $0[.a]
                {
                    $0.href = "\(Unidoc.RefsEndpoint[self.volume.symbol.package])"
                } = "all tags"
            }
        }
    }
}
