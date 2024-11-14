import HTML
import Symbols
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
        let page:Paginated<RefsTable>

        init(package:PackageMetadata,
            series:VersionSeries,
            table page:Paginated<RefsTable>)
        {
            self.package = package
            self.series = series
            self.page = page
        }
    }
}
extension Unidoc.TagsPage
{
    private
    var view:Unidoc.Permissions { self.page.table.view }
}
extension Unidoc.TagsPage:Unidoc.RenderablePage
{
    var title:String { "Tags · \(self.package.symbol)" }
}
extension Unidoc.TagsPage:Unidoc.StaticPage
{
    var location:URI
    {
        Unidoc.TagsEndpoint[self.package.symbol, self.series, page: self.page.index]
    }
}
extension Unidoc.TagsPage:Unidoc.ApplicationPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.header, { $0.class = "hero" }]
        {
            $0[.h1] = "\(self.package.symbol)"

            guard
            let repo:Unidoc.PackageRepo = self.package.repo
            else
            {
                return
            }

            $0[.p] = repo.origin.about
            $0[.div] { $0.class = "chyron" } = repo.chyron(now: format.time)
        }

        main[.h2] = self.heading
        main[.div] { $0.class = "paginated" } = self.page
        main[.footer]
        {
            $0[.a]
            {
                $0.class = "region"
                $0.href = "\(Unidoc.RefsEndpoint[self.package.symbol])"
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
}
