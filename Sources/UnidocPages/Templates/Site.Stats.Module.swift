import HTML
import MarkdownABI
import MarkdownRendering
import ModuleGraphs
import UnidocRecords
import Unidoc
import URI

extension Site.Stats
{
    struct Module
    {
        let context:IdentifiablePageContext<Unidoc.Scalar>

        let canonical:CanonicalVersion?
        let sidebar:HTML.Sidebar<Site.Stats>?

        private
        let vertex:Volume.Vertex.Culture

        init(_ context:IdentifiablePageContext<Unidoc.Scalar>,
            canonical:CanonicalVersion?,
            sidebar:HTML.Sidebar<Site.Stats>?,
            vertex:Volume.Vertex.Culture)
        {
            self.context = context
            self.canonical = canonical
            self.sidebar = sidebar
            self.vertex = vertex
        }
    }
}
extension Site.Stats.Module
{
    private
    var name:String { self.vertex.module.name }
}
extension Site.Stats.Module:RenderablePage
{
    var title:String { "\(self.name) - \(self.volume.title) Documentation" }

    var description:String?
    {
        if case .swift = self.volume.symbol.package
        {
            """
            View statistics and coverage data for \(self.name), \
            a module in the Swift standard library.
            """
        }
        else
        {
            """
            View statistics and coverage data for \(self.name), \
            a module in the \(self.volume.title) package.
            """
        }
    }
}
extension Site.Stats.Module:StaticPage
{
    var location:URI { Site.Stats[self.volume, self.vertex.shoot] }
}
extension Site.Stats.Module:ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Site.Stats.Module:VersionedPage
{
    func main(_ main:inout HTML.ContentEncoder, assets:StaticAssets)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Module (statistics)"
                $0[.span] { $0.class = "domain" } = self.volume.domain
            }

            $0[.h1] = self.name

            if  let readme:Unidoc.Scalar = self.vertex.readme
            {
                $0 ?= self.context.link(file: readme)
            }
        }

        main[.section] { $0.class = "notice canonical" } = self.canonical

        main[.section]
        {
            $0.class = "details"
        }
            content:
        {
            $0[.h2] = "Interface Breakdown"

            $0 += Unidoc.StatsBreakdown.init(
                unweighted: self.vertex.census.unweighted.decls,
                weighted: self.vertex.census.weighted.decls,
                domain: "this module")


            $0[.h2] = "Documentation Coverage"

            $0 += Unidoc.StatsBreakdown.init(
                unweighted: self.vertex.census.unweighted.coverage,
                weighted: self.vertex.census.weighted.coverage,
                domain: "this module")
        }
    }
}
