import HTTP
import MongoDB
import Symbols
import UnidocAPI
import UnidocDB
import UnidocQueries
import UnidocRender
import URI

extension Unidoc {
    @frozen public struct TagsEndpoint {
        public let query: TagsQuery
        public var value: TagsQuery.Output?

        @inlinable public init(query: TagsQuery) {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.TagsEndpoint {
    @inlinable public static subscript(
        package: Symbol.Package,
        series: Unidoc.VersionSeries,
        page index: Int
    ) -> URI {
        var uri: URI = Unidoc.ServerRoot.tags / "\(package)"
        uri["page"] = "\(index)"
        uri["beta"] = series == .prerelease ? "true" : nil
        return uri
    }
}
extension Unidoc.TagsEndpoint: Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint {
    @inlinable public static var replica: Mongo.ReadPreference { .nearest }
}
extension Unidoc.TagsEndpoint: HTTP.ServerEndpoint {
    public consuming func response(as format: Unidoc.RenderFormat) -> HTTP.ServerResponse {
        guard
        let output: Unidoc.TagsQuery.Output = self.value else {
            return .error("Query for endpoint '\(Self.self)' returned no outputs!")
        }

        let view: Unidoc.Permissions = format.access.permissions(
            package: output.package,
            user: output.user
        )

        let table: Unidoc.Paginated<Unidoc.RefsTable> = .init(
            table: .init(
                package: output.package.symbol,
                rows: output.tags,
                view: view,
                type: self.query.filter == .release ? .releases : .prereleases
            ),
            index: self.query.page,
            truncated: output.tags.count >= self.query.limit
        )

        let page: Unidoc.TagsPage = .init(
            package: output.package,
            series: self.query.filter,
            table: table
        )

        return .ok(page.resource(format: format))
    }
}
