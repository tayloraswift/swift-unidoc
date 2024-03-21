import HTML
import HTTP
import MarkdownABI
import MongoDB
import SwiftinitRender
import UnidocDB
import UnidocQueries
import UnidocRecords

extension Swiftinit
{
    @frozen public
    struct ExportEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
    {
        public
        let rateLimit:HTTP.Resource.Headers.RateLimit
        public
        let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent>
        public
        var value:Unidoc.VertexOutput?

        @inlinable public
        init(
            rateLimit:HTTP.Resource.Headers.RateLimit,
            query:Unidoc.VertexQuery<Unidoc.LookupAdjacent>)
        {
            self.rateLimit = rateLimit
            self.query = query
            self.value = nil
        }
    }
}
extension Swiftinit.ExportEndpoint:Swiftinit.VertexEndpoint, HTTP.ServerEndpoint
{
    public
    typealias VertexLayer = Swiftinit.Docs

    public
    func failure(
        matches:consuming [Unidoc.AnyVertex],
        tree:consuming Unidoc.TypeTree?,
        with context:Unidoc.PeripheralPageContext,
        format:Swiftinit.RenderFormat) throws -> HTTP.ServerResponse
    {
        if  matches.isEmpty
        {
            return .notFound("No such article\n")
        }
        else
        {
            return .multiple("Multiple matching articles\n")
        }
    }

    public
    func success(
        vertex apex:consuming Unidoc.AnyVertex,
        groups:consuming [Unidoc.AnyGroup],
        tree:consuming Unidoc.TypeTree?,
        with context:Unidoc.AbsolutePageContext,
        format:Swiftinit.RenderFormat) throws -> HTTP.ServerResponse
    {
        let article:Unidoc.ArticleVertex
        switch apex
        {
        case .article(let apex):    article = apex
        case let invalid:           throw Unidoc.VertexTypeError.reject(invalid)
        }

        let outlines:[Unidoc.Outline] = article.outlinesConcatenated
        let overview:Markdown.ProseSection? = article.overview.map
        {
            .init(context, bytecode: $0.markdown, outlines: outlines)
        }
        let details:Markdown.ProseSection? = article.details.map
        {
            .init(context, bytecode: $0.markdown, outlines: outlines)
        }

        let html:HTML = .init
        {
            $0[.section, { $0.class = "introduction" }]
            {
                $0[.h1] = article.headline.safe

            }
            $0[.section, { $0.class = "details literature" }]
            {
                $0 ?= overview
                $0 ?= details
            }
        }

        return .ok(.init(
            headers: .init(canonical: nil, rateLimit: self.rateLimit),
            content: .binary(html.utf8),
            type: .text(.plain, charset: .utf8),
            gzip: false,
            hash: nil))
    }
}
