import HTML
import Symbols
import UnixTime
import URI

extension Unidoc
{
    struct TagsPage
    {
        private
        let package:PackageMetadata

        private
        let series:VersionSeries
        private
        let index:Int
        private
        let limit:Int
        private
        let table:RefsTable

        private
        let more:Bool

        init(package:PackageMetadata,
            series:VersionSeries,
            index:Int,
            limit:Int,
            table:RefsTable,
            more:Bool)
        {
            self.package = package
            self.series = series
            self.index = index
            self.limit = limit
            self.table = table
            self.more = more
        }
    }
}
extension Unidoc.TagsPage
{
    private
    var view:Unidoc.Permissions { self.table.view }
}
extension Unidoc.TagsPage:Unidoc.RenderablePage
{
    var title:String { "Tags · \(self.package.symbol)" }
}
extension Unidoc.TagsPage:Unidoc.StaticPage
{
    var location:URI
    {
        Unidoc.TagsEndpoint[self.package.symbol, self.series, page: self.index]
    }
}
extension Unidoc.TagsPage:Unidoc.ApplicationPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.h1] = "\(self.package.symbol)"

            if  let repo:Unidoc.PackageRepo = self.package.repo
            {
                $0 += Unidoc.PackageBanner.init(repo: repo, now: .now())
            }
        }

        main[.section, { $0.class = "details" }]
        {
            $0[.h2] = self.heading
            $0[.nav, { $0.class = "paginator" }]
            {
                if  self.index > 0
                {
                    $0[.a] { $0.href = "\(self.prev)" } = "prev"
                }
                else
                {
                    $0[.span] = "prev"
                }

                if  self.more
                {
                    $0[.a] { $0.href = "\(self.next)" } = "next"
                }
                else
                {
                    $0[.span] = "next"
                }
            }

            $0[.table] { $0.class = "tags" } = self.table

            $0[.a]
            {
                $0.class = "area"
                $0.href = "\(Unidoc.TagsEndpoint[self.package.symbol])"
            } = "Back to repo details"
        }
    }
}
extension Unidoc.TagsPage
{
    private
    var heading:Heading
    {
        switch self.series
        {
        case .release:      .releases
        case .prerelease:   .prereleases
        }
    }

    private
    var prev:URI { Unidoc.TagsEndpoint[self.package.symbol, self.series, page: self.index - 1] }
    private
    var next:URI { Unidoc.TagsEndpoint[self.package.symbol, self.series, page: self.index + 1] }
}
