import HTTP
import MongoDB
import UnidocDB
import UnidocQueries
import UnidocRecords
import UnidocRender

extension Unidoc {
    @frozen public struct DocsEndpoint: Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint {
        public let query: VertexQuery<LookupAdjacent>
        public var value: VertexOutput?

        @inlinable public init(query: VertexQuery<LookupAdjacent>) {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.DocsEndpoint: Unidoc.VertexLayer {
    @inlinable public static var docs: Unidoc.ServerRoot { .docs }

    @inlinable public static var docc: Unidoc.ServerRoot { .docc }

    @inlinable public static var hist: Unidoc.ServerRoot { .hist }
}
extension Unidoc.DocsEndpoint: Unidoc.VertexEndpoint {
    public typealias VertexLayer = Self

    public func success(
        vertex apex: Unidoc.AnyVertex,
        groups: [Unidoc.AnyGroup],
        tree: Unidoc.TypeTree?,
        with context: Unidoc.InternalPageContext,
        format: Unidoc.RenderFormat
    ) throws -> HTTP.ServerResponse {
        let resource: HTTP.Resource
        switch apex {
        case .article(let apex):
            let cone: Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page: ArticlePage = try .init(cone: cone, apex: apex, tree: tree)
            resource = page.resource(format: format)

        case .culture(let apex):
            let cone: Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page: ModulePage = .init(cone: cone, apex: apex, tree: tree)
            resource = page.resource(format: format)

        case .decl(let apex):
            let cone: Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page: DeclPage = try .init(cone: cone, apex: apex, tree: tree)
            resource = page.resource(format: format)

        case .file:
            throw Unidoc.VertexTypeError.file

        case .product(let apex):
            let cone: Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page: ProductPage = .init(cone: cone, apex: apex)
            resource = page.resource(format: format)

        case .foreign(let apex):
            let cone: Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page: ForeignPage = try .init(cone: cone, apex: apex)
            resource = page.resource(format: format)

        case .landing(let apex):
            let cone: Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page: PackagePage = .init(cone: cone, apex: apex)
            resource = page.resource(format: format)
        }

        return .ok(resource)
    }
}
