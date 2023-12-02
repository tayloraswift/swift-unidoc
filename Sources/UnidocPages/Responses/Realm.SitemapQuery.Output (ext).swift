import HTTP
import Media
import UnidocQueries
import UnidocRecords
import UnidocSelectors
import URI

extension Realm.SitemapQuery.Output:HTTP.ServerResponseFactory
{
    /// Generates a plain text sitemap for the given package.
    ///
    /// We don’t have granular enough `<lastmod>` information to motivate generating XML
    /// sitemaps, and all other XML sitemap features (like `<priority>`) are irrelevant to us,
    /// since Google ignores them. Therefore, we use the plain text format.
    public
    func response(with assets:StaticAssets, as _:AcceptType) -> HTTP.ServerResponse
    {
        let prefix:String = "https://swiftinit.org/\(Site.Docs.root)/\(self.package)"
        var string:String = ""

        for page:Volume.Shoot in self.sitemap.elements
        {
            var uri:URI = []

            uri.path += page.stem
            uri["hash"] = page.hash?.description

            string += "\(prefix)\(uri)\n"
        }

        return .ok(.init(content: .string(string),
            type: .text(.plain, charset: .utf8),
            hash: self.sitemap.hash))
    }
}