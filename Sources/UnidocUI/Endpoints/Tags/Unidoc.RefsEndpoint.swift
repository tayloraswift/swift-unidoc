import HTTP
import MongoDB
import Symbols
import UnidocDB
import UnidocQueries
import UnidocRender
import URI

extension Unidoc
{
    @frozen public
    struct RefsEndpoint
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
extension Unidoc.RefsEndpoint
{
    @inlinable public static
    subscript(package:Symbol.Package) -> URI { Unidoc.ServerRoot.tags / "\(package)" }
}
extension Unidoc.RefsEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Unidoc.RefsEndpoint:HTTP.ServerEndpoint
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

        let view:Unidoc.Permissions = format.security.permissions(package: output.package,
            user: output.user)

        let releases:Int = output.versions.reduce(into: 0)
        {
            if  $1.edition.release
            {
                $0 += 1
            }
        }

        let dependents:Unidoc.Paginated<Unidoc.ConsumersTable> = .init(
            table: .init(dependency: output.package.symbol, rows: output.dependents),
            index: -1,
            truncated: output.dependents.count >= self.query.limitDependents)

        let versions:Unidoc.Paginated<Unidoc.RefsTable> = .init(
            table: .init(package: output.package.symbol,
                //  Reverse order, because we want the latest versions to come first.
                rows: output.versions.sorted { $0.edition.ordering > $1.edition.ordering },
                view: view,
                type: .versions),
            index: -1,
            truncated: releases >= self.query.limitTags)

        let page:Unidoc.VersionsPage = .init(package: output.package,
            dependents: dependents,
            versions: versions,
            branches: output.branches,
            aliases: output.aliases,
            build: output.build,
            realm: output.realm)

        return .ok(page.resource(format: format))
    }
}
