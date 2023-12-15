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
        let visibleInFeed:Bool

        @inlinable public
        init(edition:Edition,
            sitemap:SitemapDelta?,
            visibleInFeed:Bool = false)
        {
            self.edition = edition
            self.sitemap = sitemap
            self.visibleInFeed = visibleInFeed
        }
    }
}
