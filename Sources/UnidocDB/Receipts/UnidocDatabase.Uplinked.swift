import Unidoc
import UnidocRecords

extension UnidocDatabase
{
    @frozen public
    struct Uplinked:Equatable, Sendable
    {
        public
        let edition:Unidoc.Edition
        public
        let sitemap:Unidoc.Sitemap.Delta?
        public
        let visibleInFeed:Bool

        @inlinable public
        init(edition:Unidoc.Edition,
            sitemap:Unidoc.Sitemap.Delta?,
            visibleInFeed:Bool = false)
        {
            self.edition = edition
            self.sitemap = sitemap
            self.visibleInFeed = visibleInFeed
        }
    }
}
