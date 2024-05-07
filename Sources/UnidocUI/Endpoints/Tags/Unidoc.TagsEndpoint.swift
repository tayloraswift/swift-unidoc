import HTTP
import MongoDB
import SemanticVersions
import Symbols
import UnidocAPI
import UnidocDB
import UnidocQueries
import UnidocRender
import URI

extension Unidoc
{
    @frozen public
    struct TagsEndpoint
    {
        public
        let query:VersionsQuery
        public
        var value:VersionsQuery.Output?

        @inlinable public
        init(query:VersionsQuery)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.TagsEndpoint
{
    @inlinable public static
    subscript(package:Symbol.Package) -> URI { Unidoc.ServerRoot.tags / "\(package)" }

    @inlinable public static
    subscript(package:Symbol.Package, series:Unidoc.VersionSeries, page index:Int) -> URI
    {
        var uri:URI = Unidoc.ServerRoot.tags / "\(package)"
        uri["page"] = "\(index)"
        uri["beta"] = series == .prerelease ? "true" : nil
        return uri
    }
}
extension Unidoc.TagsEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Unidoc.TagsEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Unidoc.RenderFormat) -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.VersionsQuery.Output = self.value
        else
        {
            return .error("Query for endpoint '\(Self.self)' returned no outputs!")
        }

        /// In development mode, everyone is an administratrix!
        let view:Unidoc.Permissions = .init(package: output.package,
            user: format.secure ? output.user : output.user?.as(.administratrix))

        switch self.query.filter
        {
        case .tags(limit: let limit, page: let index, series: let series):
            let table:Unidoc.TagsTable = .init(
                package: output.package.symbol,
                versions: output.versions.list,
                view: view,
                more: output.versions.list.count == limit)

            let page:Unidoc.TagsPage = .init(package: output.package,
                series: series,
                index: index,
                limit: limit,
                table: table)

            return .ok(page.resource(format: format))

        case .none(limit: let limit):
            let releases:Int = output.versions.list.reduce(into: 0)
            {
                if  $1.edition.release
                {
                    $0 += 1
                }
            }

            let table:Unidoc.TagsTable = .init(
                package: output.package.symbol,
                _tagless: output.versions.top,
                versions: output.versions.list.sorted
                {
                    $0.edition.ordering < $1.edition.ordering
                },
                view: view,
                more: releases == limit)

            let page:Unidoc.VersionsPage = .init(package: output.package,
                aliases: output.aliases,
                build: output.build,
                realm: output.realm,
                table: table)

            return .ok(page.resource(format: format))
        }
    }
}
