import HTML
import HTTP
import Media
import MongoDB
import UnidocDB
import UnidocQueries
import UnidocRecords
import UnidocRender
import URI

extension Unidoc
{
    public
    protocol VertexEndpoint:Mongo.SingleOutputEndpoint
        where Query.Iteration.BatchElement == Unidoc.VertexOutput
    {
        associatedtype VertexContext:Unidoc.VertexContext
        associatedtype VertexLayer:Unidoc.VertexLayer

        func failure(format:Unidoc.RenderFormat) throws -> HTTP.ServerResponse

        func failure(
            matches:consuming [Unidoc.AnyVertex],
            tree:consuming Unidoc.TypeTree?,
            with context:Unidoc.PeripheralPageContext,
            format:Unidoc.RenderFormat) throws -> HTTP.ServerResponse

        func success(
            vertex:consuming Unidoc.AnyVertex,
            groups:consuming [Unidoc.AnyGroup],
            tree:consuming Unidoc.TypeTree?,
            with context:VertexContext,
            format:Unidoc.RenderFormat) throws -> HTTP.ServerResponse
    }
}
extension Unidoc.VertexEndpoint
{
    /// All vertex endpoints should be read-only, and they read from secondary replicas when
    /// possible.
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }

    public
    func failure(format:Unidoc.RenderFormat) -> HTTP.ServerResponse
    {
        .notFound("Snapshot not found.\n")
    }

    public
    func failure(
        matches:consuming [Unidoc.AnyVertex],
        tree:consuming Unidoc.TypeTree?,
        with context:Unidoc.PeripheralPageContext,
        format:Unidoc.RenderFormat) -> HTTP.ServerResponse
    {
        if  let choices:Unidoc.DocsEndpoint.MultipleFoundPage = .init(context, matches: matches)
        {
            return .multiple(choices.resource(format: format))
        }
        else
        {
            //  We currently don’t have any actual means of obtaining a type tree in this
            //  situation, but in theory, we could.
            let display:Unidoc.DocsEndpoint.NotFoundPage = .init(context,
                sidebar: .module(volume: context.volume, tree: tree))

            return .notFound(display.resource(format: format))
        }
    }
}
extension Unidoc.VertexEndpoint where Self:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Unidoc.RenderFormat) throws -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.VertexOutput = self.value,
        let principal:Unidoc.PrincipalOutput = output.principal
        else
        {
            return try self.failure(format: format)
        }

        if  let vertex:Unidoc.AnyVertex = principal.vertex
        {
            let vertexContext:VertexContext = .init(canonical: .init(principal: principal,
                    vertex: output.canonical,
                    layer: VertexLayer.self),
                principal: principal.volume,
                secondary: output.volumes,
                packages: output.packages,
                vertices: .init(principal: vertex, secondary: output.vertices))

            _ = consume output

            let groups:[Unidoc.AnyGroup] = principal.groups
            let tree:Unidoc.TypeTree? = principal.tree

            //  Note: noun tree won’t exist if the module contains no declarations.
            //  (For example, an `@_exported` shim.)
            return try self.success(
                vertex: consume vertex,
                groups: consume groups,
                tree: consume tree,
                with: vertexContext,
                format: format)
        }
        else
        {
            let vertexContext:Unidoc.PeripheralPageContext = .init(canonical: nil,
                principal: principal.volume,
                secondary: output.volumes,
                packages: output.packages,
                vertices: .init(secondary: principal.matches))

            return try self.failure(matches: principal.matches,
                tree: principal.tree,
                with: vertexContext,
                format: format)
        }
    }
}
