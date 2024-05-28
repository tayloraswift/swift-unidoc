import HTML
import MarkdownABI
import MarkdownRendering
import Unidoc
import UnidocRecords
import URI

extension Unidoc.StatsEndpoint
{
    struct ModulePage
    {
        let context:Unidoc.InternalPageContext

        let sidebar:Unidoc.Sidebar<Unidoc.StatsEndpoint>?

        private
        let vertex:Unidoc.CultureVertex

        init(_ context:Unidoc.InternalPageContext,
            sidebar:Unidoc.Sidebar<Unidoc.StatsEndpoint>?,
            vertex:Unidoc.CultureVertex)
        {
            self.context = context
            self.sidebar = sidebar
            self.vertex = vertex
        }
    }
}
extension Unidoc.StatsEndpoint.ModulePage
{
    private
    var demonym:Unidoc.ModuleDemonym
    {
        .init(
            language: self.vertex.module.language ?? .swift,
            type: self.vertex.module.type)
    }

    private
    var name:String { self.vertex.module.name }

    private
    var stem:Unidoc.Stem { self.vertex.stem }
}
extension Unidoc.StatsEndpoint.ModulePage:Unidoc.RenderablePage
{
    var title:String { "\(self.name) · \(self.volume.title) statistics" }

    var description:String?
    {
        self.volume.symbol.package == .swift ?
        """
        View statistics and coverage data for \(self.name), \
        \(self.demonym.phrase) in the Swift standard library.
        """ :
        """
        View statistics and coverage data for \(self.name), \
        \(self.demonym.phrase) in the \(self.volume.title) package.
        """
    }
}
extension Unidoc.StatsEndpoint.ModulePage:Unidoc.StaticPage
{
    var location:URI { Unidoc.StatsEndpoint[self.volume, self.vertex.route] }
}
extension Unidoc.StatsEndpoint.ModulePage:Unidoc.ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Unidoc.StatsEndpoint.ModulePage:Unidoc.VertexPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        let back:String = "\(Unidoc.DocsEndpoint[self.volume, self.vertex.route])"

        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Module details"
                $0[.span] { $0.class = "domain" } = self.context.subdomain(self.vertex.route)
            }

            $0[.h1] = "\(self.name) metrics"

            $0[.p]
            {
                $0 += "Statistics and coverage details for the "
                $0[.code] { $0[.a] { $0.href = back } = self.name }
                $0 += " module."
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
            } = self.vertex.census.unweighted.coverage.chart
            {
                """
                \($1) percent of the declarations in \(self.name) are \($0.name)
                """
            }
            //  Right now we do not have coverage weights, so displaying the same pie chart
            //  twice would be redundant.
            /*
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
            */

            $0[.h2] = Unidoc.StatsHeading.interfaceBreakdown

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

            $0[.h2] = Unidoc.StatsHeading.interfaceLayers

            $0[.h3] = "Declarations"
            $0[.figure]
            {
                $0.class = "chart spis"
            } = self.vertex.census.interfaces.chart
            {
                """
                \($1) percent of the declarations in \(self.name) are \($0.name)
                """
            }
        }
    }
}
