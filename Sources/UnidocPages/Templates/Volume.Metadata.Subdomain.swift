import HTML
import UnidocRecords

extension Unidoc.VolumeMetadata
{
    struct Subdomain
    {
        private
        let volume:Unidoc.VolumeMetadata
        private
        let culture:Culture

        init(_ volume:Unidoc.VolumeMetadata, culture:Culture)
        {
            self.volume = volume
            self.culture = culture
        }
    }
}
extension Unidoc.VolumeMetadata.Subdomain:HyperTextOutputStreamable
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
            switch self.culture
            {
            case .original(let module):
                $0[.span] { $0.class = "culture" } = module

            case .colonial(let module, let culture):
                $0[.span] { $0.class = "culture" } = culture
                $0[.span]
                {
                    $0.class = "extends"
                    $0.title = """
                    \(culture.display), the current module, extends a type defined in \
                    \(module.display), a different module.
                    """
                } = "->"
                $0[.span] { $0.class = "namespace" } = module
            }
        }
    }
}
