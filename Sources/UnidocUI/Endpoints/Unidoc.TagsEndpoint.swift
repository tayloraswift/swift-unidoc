import HTTP
import MongoDB
import UnidocRender
import UnidocDB
import UnidocQueries

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
        let view:Swiftinit.Permissions = .init(package: output.package,
            user: format.secure ? output.user : output.user?.as(.administratrix))

        let tags:Swiftinit.TagsTable

        switch self.query.filter
        {
        case .tags(limit: let limit, page: _, series: let series):
            let list:[Unidoc.Versions.Tag]
            switch series
            {
            case .release:      list = output.versions.releases
            case .prerelease:   list = output.versions.prereleases
            }

            tags = .init(
                package: output.package.symbol,
                tagged: list,
                view: view,
                more: list.count == limit)

        case .none(limit: let limit):
            var prereleases:ArraySlice<Unidoc.Versions.Tag> = output.versions.prereleases[...]
            var releases:ArraySlice<Unidoc.Versions.Tag> = output.versions.releases[...]

            //  Merge the two pre-sorted arrays into a single sorted array.
            var list:[Unidoc.Versions.Tag] = []
                list.reserveCapacity(prereleases.count + releases.count)
            while
                let prerelease:Unidoc.Versions.Tag = prereleases.first,
                let release:Unidoc.Versions.Tag = releases.first
            {
                if  release.edition.patch < prerelease.edition.patch
                {
                    list.append(prerelease)
                    prereleases.removeFirst()
                }
                else
                {
                    list.append(release)
                    releases.removeFirst()
                }
            }

            //  Append any remaining items.
            list += prereleases
            list += releases

            tags = .init(
                package: output.package.symbol,
                tagless: output.versions.top,
                tagged: list,
                view: view,
                more: output.versions.releases.count == limit)
        }

        let page:Swiftinit.TagsPage = .init(package: output.package,
            aliases: output.aliases,
            build: output.build,
            realm: output.realm,
            table: tags,
            shown: self.query.filter)

        return .ok(page.resource(format: format))
    }
}
