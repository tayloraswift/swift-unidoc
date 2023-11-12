import HTTP
import MD5
import ModuleGraphs
import MongoDB
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
        let package:PackageIdentifier
        let tag:MD5?

        init(package:PackageIdentifier, tag:MD5?)
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
        let sitemap:Volume.Sitemap<PackageIdentifier> = try await server.db.unidoc.sitemap(
            package: self.package,
            with: session)
        else
        {
            return nil
        }

        let prefix:String = "https://swiftinit.org/\(Site.Docs.root)/\(self.package)"
        var string:String = ""
        var i:Int = sitemap.lines.startIndex

        while let j:Int = sitemap.lines[i...].firstIndex(of: 0x0A)
        {
            defer { i = sitemap.lines.index(after: j) }

            let shoot:Volume.Shoot = .deserialize(from: sitemap.lines[i..<j])
            var uri:URI = []

            uri.path += shoot.stem
            uri["hash"] = shoot.hash?.description

            string += "\(prefix)\(uri)\n"
        }

        var resource:HTTP.Resource = .init(content: .string(string),
            type: .text(.plain, charset: .utf8))

        resource.optimize(tag: self.tag)

        return .ok(resource)
    }
}
