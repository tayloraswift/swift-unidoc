import HTML
import UnidocRecords

extension Volume.Metadata
{
    struct Subdomain
    {
        private
        let volume:Volume.Metadata
        private
        let culture:Culture

        init(_ volume:Volume.Metadata, culture:Culture)
        {
            self.volume = volume
            self.culture = culture
        }
    }
}
extension Volume.Metadata.Subdomain:HyperTextOutputStreamable
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
