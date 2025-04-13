import HTTP
import Media
import MongoDB
import UnidocDB
import UnidocQueries
import UnidocRender

extension Unidoc
{
    @frozen public
    struct HomeEndpoint
    {
        public
        let query:ActivityQuery
        public
        var value:ActivityQuery.Output?

        @inlinable public
        init(query:ActivityQuery)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.HomeEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Unidoc.HomeEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Unidoc.RenderFormat) -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.ActivityQuery.Output = self.value
        else
        {
            return .error("Query for endpoint '\(Self.self)' returned no outputs!")
        }

        let featured:
        (
            blogPosts:[Unidoc.ArticleVertex],
            tutorials:[Unidoc.ActivityQuery.Featured<Unidoc.ArticleVertex>]
        ) = output.featured.reduce(into: ([], []))
        {
            guard case .article(let article) = $1.article
            else
            {
                return
            }
            if  $1.package == "__swiftinit"
            {
                $0.blogPosts.append(article)
            }
            else
            {
                $0.tutorials.append(.init(package: $1.package, article: article))
            }
        }

        let page:Unidoc.HomePage = .init(
            repo: output.repo,
            docs: output.docs,
            blogPosts: featured.blogPosts,
            tutorials: featured.tutorials)

        return .ok(page.resource(format: format))
    }
}
