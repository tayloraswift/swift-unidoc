import HTTP
import MongoDB
import Symbols
import UnidocRender
import UnidocDB
import UnidocQueries
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
    subscript(package:Symbol.Package, page index:Int, beta betas:Bool = false) -> URI
    {
        var uri:URI = Unidoc.ServerRoot.tags / "\(package)"
        uri["page"] = "\(index)"
        uri["beta"] = betas ? "true" : nil
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
            let list:[Unidoc.Versions.Tag]
            switch series
            {
            case .release:      list = output.versions.releases
            case .prerelease:   list = output.versions.prereleases
            }

            let tags:Unidoc.TagsTable = .init(
                package: output.package.symbol,
                tagged: list,
                view: view,
                more: list.count == limit)

            let page:Unidoc.TagsPage = .init(package: output.package,
                series: series,
                index: index,
                limit: limit,
                table: tags)

            return .ok(page.resource(format: format))

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

            let tags:Unidoc.TagsTable = .init(
                package: output.package.symbol,
                tagless: output.versions.top,
                tagged: list,
                view: view,
                more: output.versions.releases.count == limit)

            let page:Unidoc.VersionsPage = .init(package: output.package,
                aliases: output.aliases,
                build: output.build,
                realm: output.realm,
                table: tags)

            return .ok(page.resource(format: format))
        }
    }
}
