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
        let sitemap:Realm.Sitemap.Delta?

        @inlinable public
        init(edition:Unidoc.Edition, sitemap:Realm.Sitemap.Delta?)
        {
            self.edition = edition
            self.sitemap = sitemap
        }
    }
}
