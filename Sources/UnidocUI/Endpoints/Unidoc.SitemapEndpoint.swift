import HTTP
import Media
import MongoDB
import UnidocRender
import UnidocDB
import UnidocQueries
import UnidocRecords
import URI

extension Unidoc
{
    @frozen public
    struct SitemapEndpoint
    {
        public
        let query:SitemapQuery
        public
        var value:SitemapQuery.Output?

        @inlinable public
        init(query:SitemapQuery)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.SitemapEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Unidoc.SitemapEndpoint:HTTP.ServerEndpoint
{
    /// Generates a plain text sitemap for the given package.
    ///
    /// We don’t have granular enough `<lastmod>` information to motivate generating XML
    /// sitemaps, and all other XML sitemap features (like `<priority>`) are irrelevant to us,
    /// since Google ignores them. Therefore, we use the plain text format.
    public consuming
    func response(as _:Unidoc.RenderFormat) -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.SitemapQuery.Output = self.value
        else
        {
            return .notFound("Query for endpoint '\(Self.self)' returned no outputs!")
        }

        let prefix:String = "https://swiftinit.org\(Unidoc.ServerRoot.docs)/\(output.package)"
        var string:String = ""

        for page:Unidoc.Shoot in output.sitemap.elements
        {
            var uri:URI = []

            uri.path += page.stem
            uri["hash"] = page.hash?.description

            string += "\(prefix)\(uri)\n"
        }

        return .ok(.init(content: .init(
                body: .string(string),
                type: .text(.plain, charset: .utf8)),
            hash: output.sitemap.hash))
    }
}
