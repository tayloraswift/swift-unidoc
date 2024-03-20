import HTML
import HTTP
import Media
import MongoDB
import SwiftinitRender
import UnidocDB
import UnidocQueries
import UnidocRecords
import URI

extension Swiftinit
{
    public
    protocol VertexEndpoint:Mongo.SingleOutputEndpoint
        where Query.Iteration.BatchElement == Unidoc.VertexOutput
    {
        associatedtype VertexCache:Swiftinit.VertexCache = Swiftinit.Vertices
        associatedtype VertexLayer:Swiftinit.VertexLayer

        static
        func response(
            vertex:consuming Unidoc.AnyVertex,
            groups:consuming [Unidoc.AnyGroup],
            tree:consuming Unidoc.TypeTree?,
            with context:IdentifiableResponseContext<VertexCache>) throws -> HTTP.ServerResponse
    }
}
extension Swiftinit.VertexEndpoint
{
    /// All vertex endpoints should be read-only, and they read from secondary replicas when
    /// possible.
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Swiftinit.VertexEndpoint where Self:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Swiftinit.RenderFormat) throws -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.VertexOutput = self.value,
        let principal:Unidoc.PrincipalOutput = output.principal
        else
        {
            return .notFound(.init(
                content: .string("Snapshot not found."),
                type: .text(.plain, charset: .utf8),
                gzip: false))
        }

        guard
        let vertex:Unidoc.AnyVertex = principal.vertex
        else
        {
            let context:IdentifiablePageContext<Swiftinit.SecondaryOnly> = .init(cache: .init(
                    vertices: .init(secondary: principal.matches),
                    volumes: .init(principal: principal.volume)),
                repo: principal.repo)

            if  let choices:Swiftinit.Docs.MultipleFoundPage = .init(context,
                    matches: principal.matches)
            {
                return .multiple(choices.resource(format: format))
            }
            else
            {
                //  We currently don’t have any actual means of obtaining a type tree in this
                //  situation, but in theory, we could.
                let display:Swiftinit.Docs.NotFoundPage = .init(context,
                    sidebar: .module(volume: principal.volume, tree: principal.tree))

                return .notFound(display.resource(format: format))
            }
        }

        let vertices:Swiftinit.Vertices = .init(principal: vertex,
            secondary: output.vertices)
        let volumes:Swiftinit.Volumes = .init(principal: principal.volume,
            secondary: output.volumes)

        _ = consume output

        let context:IdentifiablePageContext<VertexCache> = .init(cache: .init(
                vertices: .form(from: consume vertices),
                volumes: volumes),
            repo: principal.repo)

        let groups:[Unidoc.AnyGroup] = principal.groups
        let tree:Unidoc.TypeTree? = principal.tree

        let canonical:CanonicalVersion? = .init(principal: /* consume */ principal,
            layer: VertexLayer.self)

        //  Note: noun tree won’t exist if the module contains no declarations.
        //  (For example, an `@_exported` shim.)
        return try Self.response(vertex: consume vertex,
            groups: consume groups,
            tree: consume tree,
            with: .init(context,
                canonical: canonical,
                format: format))
    }
}
