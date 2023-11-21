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

    private
    var stem:Volume.Stem { self.vertex.stem }
}
extension Site.Stats.Module:RenderablePage
{
    var title:String { "\(self.name) - \(self.volume.title) Statistics" }

    var description:String?
    {
        self.volume.symbol.package == .swift ?
        """
        View statistics and coverage data for \(self.name), \
        a module in the Swift standard library.
        """ :
        """
        View statistics and coverage data for \(self.name), \
        a module in the \(self.volume.title) package.
        """
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
        let back:String = "\(Site.Docs[self.volume, self.vertex.shoot])"

        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Module details"
                $0[.span] { $0.class = "domain" } = self.context.subdomain(self.vertex.shoot)
            }

            $0[.h1] = "\(self.name) metrics"

            $0[.p]
            {
                $0 += "Statistics and coverage details for the "
                $0[.code] { $0[.a] { $0.href = back } = self.name }
                $0 += " module."
            }
        }

        main[.section] { $0.class = "notice canonical" } = self.canonical

        main[.section]
        {
            $0.class = "details"
        }
            content:
        {
            let breakdown:AutomaticHeading = .interfaceBreakdown
            $0[.h2] { $0.id = breakdown.id } = breakdown

            $0[.h3] = "Declarations"
            $0[.figure]
            {
                $0.class = "chart decl"
            } = self.vertex.census.unweighted.decls.chart
            {
                """
                \($1) percent of the declarations in \(self.name) are \($0.name)
                """
            }

            $0[.h3] = "Symbols"
            $0[.figure]
            {
                $0.class = "chart decl"
            } = self.vertex.census.weighted.decls.chart
            {
                """
                \($1) percent of the symbols in \(self.name) are \($0.name)
                """
            }

            let coverage:AutomaticHeading = .documentationCoverage
            $0[.h2] { $0.id = coverage.id } = coverage

            $0[.h3] = "Declarations"
            $0[.figure]
            {
                $0.class = "chart coverage"
            } = self.vertex.census.unweighted.coverage.chart
            {
                """
                \($1) percent of the declarations in \(self.name) are \($0.name)
                """
            }

            $0[.h3] = "Symbols"
            $0[.figure]
            {
                $0.class = "chart coverage"
            } = self.vertex.census.weighted.coverage.chart
            {
                """
                \($1) percent of the symbols in \(self.name) are \($0.name)
                """
            }
        }
    }
}