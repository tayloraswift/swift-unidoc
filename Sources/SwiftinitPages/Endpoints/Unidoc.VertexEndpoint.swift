import HTML
import HTTP
import Media
import MongoDB
import SwiftinitRender
import UnidocDB
import UnidocQueries
import UnidocRecords
import URI

extension Unidoc
{
    public
    protocol VertexEndpoint:Mongo.SingleOutputEndpoint
        where Query.Iteration.BatchElement == Unidoc.VertexOutput
    {
        associatedtype VertexContext:Unidoc.VertexContext
        associatedtype VertexLayer:Unidoc.VertexLayer

        func failure(format:Swiftinit.RenderFormat) throws -> HTTP.ServerResponse

        func failure(
            matches:consuming [Unidoc.AnyVertex],
            tree:consuming Unidoc.TypeTree?,
            with context:Unidoc.PeripheralPageContext,
            format:Swiftinit.RenderFormat) throws -> HTTP.ServerResponse

        func success(
            vertex:consuming Unidoc.AnyVertex,
            groups:consuming [Unidoc.AnyGroup],
            tree:consuming Unidoc.TypeTree?,
            with context:VertexContext,
            format:Swiftinit.RenderFormat) throws -> HTTP.ServerResponse
    }
}
extension Unidoc.VertexEndpoint
{
    /// All vertex endpoints should be read-only, and they read from secondary replicas when
    /// possible.
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }

    public
    func failure(format:Swiftinit.RenderFormat) -> HTTP.ServerResponse
    {
        .notFound("Snapshot not found.\n")
    }

    public
    func failure(
        matches:consuming [Unidoc.AnyVertex],
        tree:consuming Unidoc.TypeTree?,
        with context:Unidoc.PeripheralPageContext,
        format:Swiftinit.RenderFormat) -> HTTP.ServerResponse
    {
        if  let choices:Swiftinit.Docs.MultipleFoundPage = .init(context, matches: matches)
        {
            return .multiple(choices.resource(format: format))
        }
        else
        {
            //  We currently don’t have any actual means of obtaining a type tree in this
            //  situation, but in theory, we could.
            let display:Swiftinit.Docs.NotFoundPage = .init(context,
                sidebar: .module(volume: context.volume, tree: tree))

            return .notFound(display.resource(format: format))
        }
    }
}
extension Unidoc.VertexEndpoint where Self:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Swiftinit.RenderFormat) throws -> HTTP.ServerResponse
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
            let canonical:Unidoc.CanonicalVersion? = .init(principal: principal,
                layer: VertexLayer.self)
            let vertices:Unidoc.Vertices = .init(principal: vertex,
                secondary: output.vertices)
            let volumes:Unidoc.Volumes = .init(principal: principal.volume,
                secondary: output.volumes)

            _ = consume output

            let context:VertexContext = .init(canonical: canonical,
                vertices: vertices,
                volumes: volumes,
                repo: principal.repo)

            let groups:[Unidoc.AnyGroup] = principal.groups
            let tree:Unidoc.TypeTree? = principal.tree

            //  Note: noun tree won’t exist if the module contains no declarations.
            //  (For example, an `@_exported` shim.)
            return try self.success(
                vertex: consume vertex,
                groups: consume groups,
                tree: consume tree,
                with: context,
                format: format)
        }
        else
        {
            let context:Unidoc.PeripheralPageContext = .init(canonical: nil,
                cache: .init(
                    vertices: .init(secondary: principal.matches),
                    volumes: .init(principal: principal.volume)),
                repo: principal.repo)

            return try self.failure(matches: principal.matches,
                tree: principal.tree,
                with: context,
                format: format)
        }
    }
}
