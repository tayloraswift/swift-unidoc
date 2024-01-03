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
    typealias VertexEndpoint = _SwiftinitVertexEndpoint
}

/// The name of this protocol is ``Swiftinit.VertexLayer``.
public
protocol _SwiftinitVertexEndpoint:Mongo.SingleOutputEndpoint
    where Query.Iteration.BatchElement == Unidoc.VertexOutput
{
    static
    func response(
        vertex:consuming Unidoc.Vertex,
        groups:consuming [Unidoc.Group],
        tree:consuming Unidoc.TypeTree?,
        with context:IdentifiableResponseContext) throws -> HTTP.ServerResponse
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
                type: .text(.plain, charset: .utf8)))
        }

        guard
        let vertex:Unidoc.Vertex = principal.vertex
        else
        {
            let context:IdentifiablePageContext<Never?> = .init(
                principal: principal.volume,
                repo: principal.repo)

            context.vertices.add(principal.matches)

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

        let context:IdentifiablePageContext<Unidoc.Scalar> = .init(principal: vertex.id,
            volume: principal.volume,
            repo: principal.repo)
        ;
        {
            context.vertices.add($0.vertices)
            context.volumes.add($0.volumes)
        } (consume output)

        vertex.overview.map
        {
            context.outlines += $0.outlines
        }
        vertex.details.map
        {
            context.outlines += $0.outlines
        }

        let groups:[Unidoc.Group] = principal.groups
        let tree:Unidoc.TypeTree? = principal.tree

        let canonical:CanonicalVersion? = .init(principal: consume principal)

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
