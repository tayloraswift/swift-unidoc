import Unidoc

extension Unidoc
{
    @frozen public
    struct UplinkStatus:Equatable, Sendable
    {
        public
        let edition:Edition
        public
        let sitemap:SitemapDelta?
        public
        let hidden:Bool

        @inlinable public
        init(edition:Edition,
            sitemap:SitemapDelta?,
            hidden:Bool)
        {
            self.edition = edition
            self.sitemap = sitemap
            self.hidden = hidden
        }
    }
}
