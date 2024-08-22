import BSON
import HTTP
import MD5
import MongoDB
import Sitemaps
import UnidocDB
import UnidocRecords
import UnixTime

extension Unidoc
{
    /// Generates a sitemap index.
    struct LoadSitemapIndexOperation:Sendable
    {
        let tag:MD5?

        init(tag:MD5?)
        {
            self.tag = tag
        }
    }
}
extension Unidoc.LoadSitemapIndexOperation:Unidoc.PublicOperation
{
    func load(from server:Unidoc.Server,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        let db:Unidoc.DB = try await server.db.session()
        let index:XML.Sitemap = try await .index
        {
            (xml:inout XML.Sitemap.ContentEncoder) in

            try await db.sitemaps.list()
            {
                for sitemap:Unidoc.SitemapIndexEntry in $0
                {
                    xml[.sitemap]
                    {
                        $0[.loc] = """
                        https://swiftinit.org\
                        \(Unidoc.ServerRoot.docs)/\(sitemap.symbol)/all-symbols
                        """

                        guard
                        let millisecond:UnixMillisecond = sitemap.modified
                        else
                        {
                            return
                        }

                        let modified:UnixAttosecond = .init(millisecond)

                        $0[.lastmod] = modified.timestamp.map
                        {
                            "\($0.date.year)-\($0.date.mm)-\($0.date.dd)"
                        }
                    }
                }
            }
        }

        var resource:HTTP.Resource = .init(content: .init(
            body: .binary(index.utf8),
            type: .application(.xml, charset: .utf8)))

        resource.optimize(tag: self.tag)

        return .ok(resource)
    }
}
