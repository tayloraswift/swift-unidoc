import HTTP
import MongoDB
import SwiftinitRender
import UnidocDB
import UnidocQueries
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct DocsEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
    {
        public
        let query:VertexQuery<LookupAdjacent>
        public
        var value:VertexOutput?

        @inlinable public
        init(query:VertexQuery<LookupAdjacent>)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.DocsEndpoint:Unidoc.VertexEndpoint, HTTP.ServerEndpoint
{
    public
    typealias VertexLayer = Swiftinit.Docs

    public
    func success(
        vertex apex:consuming Unidoc.AnyVertex,
        groups:consuming [Unidoc.AnyGroup],
        tree:consuming Unidoc.TypeTree?,
        with context:Unidoc.RelativePageContext,
        format:Swiftinit.RenderFormat) throws -> HTTP.ServerResponse
    {
        let resource:HTTP.Resource

        switch apex
        {
        case .article(let apex):
            let sidebar:Swiftinit.Sidebar<Swiftinit.Docs>? = .module(
                volume: context.volume,
                tree: tree)
            let cone:Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page:Swiftinit.Docs.ArticlePage = .init(
                sidebar: sidebar,
                cone: cone,
                apex: apex)
            resource = page.resource(format: format)

        case .culture(let apex):
            let sidebar:Swiftinit.Sidebar<Swiftinit.Docs>? = .module(
                volume: context.volume,
                tree: tree)
            let cone:Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page:Swiftinit.Docs.ModulePage = .init(
                sidebar: sidebar,
                cone: cone,
                apex: apex)
            resource = page.resource(format: format)

        case .decl(let apex):
            let sidebar:Swiftinit.Sidebar<Swiftinit.Docs>? = .module(
                volume: context.volume,
                tree: tree)
            let cone:Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page:Swiftinit.Docs.DeclPage = try .init(
                sidebar: sidebar,
                cone: cone,
                apex: apex)
            resource = page.resource(format: format)

        case .file:
            throw Unidoc.VertexTypeError.file

        case .product(let apex):
            let cone:Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page:Swiftinit.Docs.ProductPage = .init(
                cone: cone,
                apex: apex)
            resource = page.resource(format: format)

        case .foreign(let apex):
            let cone:Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page:Swiftinit.Docs.ForeignPage = try .init(
                cone: cone,
                apex: apex)
            resource = page.resource(format: format)

        case .global(let apex):
            let cone:Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page:Swiftinit.Docs.PackagePage = .init(
                cone: cone,
                apex: apex)
            resource = page.resource(format: format)
        }

        return .ok(resource)
    }
}
