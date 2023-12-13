import BSON
import HTTP
import MD5
import MongoDB
import Sitemaps
import UnidocDB
import UnidocPages
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
extension Swiftinit.SitemapIndexEndpoint:PublicEndpoint
{
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
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
                        https://swiftinit.org/\(Site.Docs.root)/\(sitemap.symbol)/all-symbols
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
                            "\($0.components.year)-\($0.components.MM)-\($0.components.DD)"
                        }
                    }
                }
            }
        }

        var resource:HTTP.Resource = .init(content: .binary(index.utf8),
            type: .application(.xml, charset: .utf8))

        resource.optimize(tag: self.tag)

        return .ok(resource)
    }
}
