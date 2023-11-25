import HTTP
import MD5
import MongoDB
import Symbols
import UnidocDB
import UnidocPages
import UnidocRecords
import UnidocSelectors
import URI

extension Server.Endpoint
{
    /// Generates a plain text sitemap for the given package.
    ///
    /// We don’t have granular enough `<lastmod>` information to motivate generating XML
    /// sitemaps, and all other XML sitemap features (like `<priority>`) are irrelevant to us,
    /// since Google ignores them. Therefore, we use the plain text format.
    struct Sitemap:Sendable
    {
        let package:Symbol.Package
        let tag:MD5?

        init(package:Symbol.Package, tag:MD5?)
        {
            self.package = package
            self.tag = tag
        }
    }
}
extension Server.Endpoint.Sitemap:PublicEndpoint
{
    func load(from server:Server) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)

        guard
        let sitemap:Realm.Sitemap = try await server.db.unidoc.sitemaps.find(by: self.package,
            with: session)
        else
        {
            return nil
        }

        let prefix:String = "https://swiftinit.org/\(Site.Docs.root)/\(self.package)"
        var string:String = ""

        for page:Volume.Shoot in sitemap.elements
        {
            var uri:URI = []

            uri.path += page.stem
            uri["hash"] = page.hash?.description

            string += "\(prefix)\(uri)\n"
        }

        var resource:HTTP.Resource = .init(content: .string(string),
            type: .text(.plain, charset: .utf8),
            hash: sitemap.hash)

        resource.optimize(tag: self.tag)

        return .ok(resource)
    }
}
