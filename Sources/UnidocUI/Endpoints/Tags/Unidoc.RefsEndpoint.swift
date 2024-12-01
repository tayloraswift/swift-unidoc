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

        let view:Unidoc.Permissions = format.access.permissions(package: output.package,
            user: output.user)

        //  Reverse order, because we want the latest versions to come first.
        let versions:[Unidoc.VersionState] = output.versions.sorted
        {
            $0.edition.ordering > $1.edition.ordering
        }
        //  Find the most recent prerelease and release tags.
        let prerelease:Unidoc.VersionState? = versions.first
        {
            $0.edition.semver != nil && !$0.edition.release
        }
        let release:Unidoc.VersionState? = versions.first
        {
            $0.edition.release
        }

        //  Determine if we are already building the prerelease and release tags.
        let submitted:(prerelease:Bool, release:Bool) = output.pendingBuilds.reduce(
            into: (false, false))
        {
            if  case $1.name.ref? = prerelease?.edition.name
            {
                $0.prerelease = true
            }
            if  case $1.name.ref? = release?.edition.name
            {
                $0.release = true
            }
        }

        let prereleaseTool:Unidoc.BuildFormTool = .shortcut(buildable: prerelease?.edition.name,
            submitted: submitted.prerelease,
            package: output.package.symbol,
            label: "Build latest prerelease",
            view: view)
        let releaseTool:Unidoc.BuildFormTool = .shortcut(buildable: release?.edition.name,
            submitted: submitted.release,
            package: output.package.symbol,
            label: "Build latest release",
            view: view)

        let buildTools:Unidoc.BuildTools = .init(
            prerelease: prereleaseTool,
            release: releaseTool,
            running: output.pendingBuilds,
            view: view,
            back: Unidoc.RefsEndpoint[output.package.symbol])

        let releaseCount:Int = output.versions.reduce(into: 0)
        {
            if  $1.edition.release
            {
                $0 += 1
            }
        }

        let builds:Unidoc.Paginated<Unidoc.CompleteBuildsTable> = .init(
            table: .init(
                package: output.package.symbol,
                rows: output.recentBuilds,
                view: view),
            index: -1,
            truncated: output.recentBuilds.count >= self.query.limitBuilds)

        let consumers:Unidoc.Paginated<Unidoc.ConsumersTable> = .init(
            table: .init(package: output.package.symbol, rows: output.dependents),
            index: -1,
            truncated: output.dependents.count >= self.query.limitDependents)

        let page:Unidoc.RefsPage = .init(package: output.package,
            consumers: consumers,
            versions: .init(
                table: .init(package: output.package.symbol,
                    rows: versions,
                    view: view,
                    type: .versions),
                index: -1,
                truncated: releaseCount >= self.query.limitTags),
            branches: output.branches,
            aliases: output.aliases,
            buildTools: buildTools,
            builds: builds,
            realm: output.realm,
            ticket: output.ticket)

        return .ok(page.resource(format: format))
    }
}
