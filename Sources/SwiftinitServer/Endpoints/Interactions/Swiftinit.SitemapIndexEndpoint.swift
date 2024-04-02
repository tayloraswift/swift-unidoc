import BSON
import HTTP
import MD5
import MongoDB
import Sitemaps
import UnidocDB
import UnidocRecords
import UnixTime

extension Swiftinit
{
    /// Generates a sitemap index.
    struct SitemapIndexEndpoint:Sendable
    {
        let tag:MD5?

        init(tag:MD5?)
        {
            self.tag = tag
        }
    }
}
extension Swiftinit.SitemapIndexEndpoint:Swiftinit.PublicEndpoint
{
    func load(from server:borrowing Swiftinit.Server,
        as _:Swiftinit.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        let db:Swiftinit.DB = server.db

        let session:Mongo.Session = try await .init(from: db.sessions)
        let index:XML.Sitemap = try await .index
        {
            (xml:inout XML.Sitemap.ContentEncoder) in

            try await db.sitemaps.list(with: session)
            {
                for sitemap:Unidoc.SitemapIndexEntry in $0
                {
                    xml[.sitemap]
                    {
                        $0[.loc] = """
                        https://swiftinit.org\
                        \(Swiftinit.Root.docs)/\(sitemap.symbol)/all-symbols
                        """

                        guard
                        let millisecond:BSON.Millisecond = sitemap.modified
                        else
                        {
                            return
                        }

                        let modified:UnixInstant = .millisecond(millisecond.value)

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
