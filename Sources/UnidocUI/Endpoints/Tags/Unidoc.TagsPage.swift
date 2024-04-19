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
        let table:TagsTable

        init(package:PackageMetadata,
            series:VersionSeries,
            index:Int,
            limit:Int,
            table:TagsTable)
        {
            self.package = package
            self.series = series
            self.index = index
            self.limit = limit
            self.table = table
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
    var title:String { "Git Tags · \(self.package.symbol)" }
}
extension Unidoc.TagsPage:Unidoc.StaticPage
{
    var location:URI
    {
        Unidoc.TagsEndpoint[self.package.symbol, page: self.index, beta: self.series == .prerelease]
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
            self.section(tags: &$0, page: index, beta: series == .prerelease)
        }
    }
}
extension Unidoc.TagsPage
{
    private
    func section(tags section:inout HTML.ContentEncoder, page:Int, beta:Bool)
    {
        section[.h2] = beta ? Heading.prereleases : Heading.releases

        section[.nav, { $0.class = "paginator" }]
        {
            if  page > 0
            {
                $0[.a]
                {
                    $0.href = """
                    \(Unidoc.TagsEndpoint[self.package.symbol, page: page - 1, beta: beta])
                    """
                } = "prev"
            }
            else
            {
                $0[.span] = "prev"
            }

            if  self.table.more
            {
                $0[.a]
                {
                    $0.href = """
                    \(Unidoc.TagsEndpoint[self.package.symbol, page: page + 1, beta: beta])
                    """
                } = "next"
            }
            else
            {
                $0[.span] = "next"
            }
        }

        section[.table] { $0.class = "tags" } = self.table

        section[.a]
        {
            $0.class = "area"
            $0.href = "\(Unidoc.TagsEndpoint[self.package.symbol])"
        } = "Back to repo details"
    }
}
