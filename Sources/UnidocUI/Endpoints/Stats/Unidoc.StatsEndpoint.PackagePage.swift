import HTML
import MarkdownABI
import MarkdownRendering
import Unidoc
import UnidocRecords
import URI

extension Unidoc.StatsEndpoint
{
    struct PackagePage
    {
        let context:Unidoc.InternalPageContext

        let sidebar:Unidoc.Sidebar<Unidoc.StatsEndpoint>

        private
        let vertex:Unidoc.LandingVertex

        init(_ context:Unidoc.InternalPageContext,
            sidebar:Unidoc.Sidebar<Unidoc.StatsEndpoint>,
            vertex:Unidoc.LandingVertex)
        {
            self.context = context
            self.sidebar = sidebar
            self.vertex = vertex
        }
    }
}
extension Unidoc.StatsEndpoint.PackagePage:Unidoc.RenderablePage
{
    var title:String { "\(self.volume.title) statistics" }

    var description:String?
    {
        self.volume.symbol.package == .swift ?
        """
        View statistics and coverage data for the Swift standard library.
        """ :
        """
        View statistics and coverage data for the \(self.volume.title) package.
        """
    }
}
extension Unidoc.StatsEndpoint.PackagePage:Unidoc.StaticPage
{
    var location:URI { Unidoc.StatsEndpoint[self.volume] }
}
extension Unidoc.StatsEndpoint.PackagePage:Unidoc.ApplicationPage
{
}
extension Unidoc.StatsEndpoint.PackagePage:Unidoc.VertexPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        let back:String = "\(Unidoc.DocsEndpoint[self.volume])"

        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Package details"
                $0[.span] { $0.class = "domain" } = self.context.volume | nil
            }

            $0[.h1] = "\(self.volume.title) metrics"

            $0[.p]
            {
                $0 += "Statistics and coverage details for the "
                $0[.a] { $0.href = back } = self.volume.title
                $0 += " package."
            }
        }

        main[.section] { $0.class = "notice canonical" } = self.context.canonical

        main[.section]
        {
            $0.class = "details"
        }
            content:
        {
            $0[.h2] = Unidoc.StatsHeading.documentationCoverage

            $0[.h3] = "Declarations"
            $0[.figure]
            {
                $0.class = "chart coverage"
            } = self.vertex.snapshot.census.unweighted.coverage.chart
            {
                """
                \($1) percent of the declarations in \(self.volume.title) are \($0.name)
                """
            }

            $0[.h2] = Unidoc.StatsHeading.interfaceBreakdown

            $0[.h3] = "Declarations"
            $0[.figure]
            {
                $0.class = "chart decl"
            } = self.vertex.snapshot.census.unweighted.decls.chart
            {
                """
                \($1) percent of the declarations in \(self.volume.title) are \($0.name)
                """
            }

            $0[.h3] = "Symbols"
            $0[.figure]
            {
                $0.class = "chart decl"
            } = self.vertex.snapshot.census.weighted.decls.chart
            {
                """
                \($1) percent of the symbols in \(self.volume.title) are \($0.name)
                """
            }

            $0[.h2] = Unidoc.StatsHeading.interfaceLayers
            $0[.h3] = "Declarations"
            $0[.figure]
            {
                $0.class = "chart spis"
            } = self.vertex.snapshot.census.interfaces.chart
            {
                """
                \($1) percent of the declarations in \(self.volume.title) are \($0.name)
                """
            }
        }
    }
}
