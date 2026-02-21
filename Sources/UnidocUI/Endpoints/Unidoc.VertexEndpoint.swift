import HTML
import HTTP
import Media
import MongoDB
import UnidocDB
import UnidocQueries
import UnidocRecords
import UnidocRender
import URI

extension Unidoc {
    public protocol VertexEndpoint: Mongo.SingleOutputEndpoint, Sendable
        where Query.Iteration.BatchElement == Unidoc.VertexOutput {
        associatedtype VertexContext: Unidoc.VertexContext
        associatedtype VertexLayer: Unidoc.VertexLayer

        func failure(
            matches: [Unidoc.AnyVertex],
            tree: Unidoc.TypeTree?,
            with context: Unidoc.PeripheralPageContext,
            format: Unidoc.RenderFormat
        ) throws -> HTTP.ServerResponse

        func success(
            vertex: Unidoc.AnyVertex,
            groups: [Unidoc.AnyGroup],
            tree: Unidoc.TypeTree?,
            with context: VertexContext,
            format: Unidoc.RenderFormat
        ) throws -> HTTP.ServerResponse
    }
}
extension Unidoc.VertexEndpoint {
    /// All vertex endpoints should be read-only, and they read from secondary replicas when
    /// possible.
    @inlinable public static var replica: Mongo.ReadPreference { .nearest }

    public func failure(
        matches: [Unidoc.AnyVertex],
        tree: Unidoc.TypeTree?,
        with context: Unidoc.PeripheralPageContext,
        format: Unidoc.RenderFormat
    ) -> HTTP.ServerResponse {
        if  let choices: Unidoc.DocsEndpoint.MultipleFoundPage = .init(
                context,
                matches: matches
            ) {
            return .multiple(choices.resource(format: format))
        } else {
            //  We currently don’t have any actual means of obtaining a type tree in this
            //  situation, but in theory, we could.
            let display: Unidoc.DocsEndpoint.NotFoundPage = .init(
                context,
                sidebar: .module(volume: context.volume, origin: nil, tree: tree)
            )

            return .notFound(display.resource(format: format))
        }
    }
}
extension Unidoc.VertexEndpoint {
    public func response(
        from output: Unidoc.VertexOutput,
        as format: Unidoc.RenderFormat
    ) throws -> HTTP.ServerResponse {
        var format: Unidoc.RenderFormat = format
        for package: Unidoc.PackageMetadata in output.adjacentPackages {
            if  package.id == output.principalVolume.id.package {
                format.theme = package.settings.theme
            }
        }

        if  let principalVertex: Unidoc.AnyVertex = output.principalVertex {
            let genericContext: VertexContext = .init(
                canonical: .init(
                    principalVolume: output.principalVolume,
                    principalVertex: output.principalVertex,
                    canonicalVolume: output.canonicalVolume,
                    canonicalVertex: output.canonicalVertex,
                    layer: VertexLayer.self
                ),
                principal: output.principalVolume,
                secondary: output.adjacentVolumes,
                packages: output.adjacentPackages,
                vertices: .init(principal: principalVertex, secondary: output.adjacentVertices)
            )

            //  Note: noun tree won’t exist if the module contains no declarations.
            //  (For example, an `@_exported` shim.)
            return try self.success(
                vertex: principalVertex,
                groups: output.principalGroups,
                tree: output.tree,
                with: genericContext,
                format: format
            )
        } else {
            let peripheral: Unidoc.PeripheralPageContext = .init(
                canonical: nil,
                principal: output.principalVolume,
                secondary: output.adjacentVolumes,
                packages: output.adjacentPackages,
                vertices: .init(secondary: output.matches)
            )

            return try self.failure(
                matches: output.matches,
                tree: output.tree,
                with: peripheral,
                format: format
            )
        }
    }
}
