import HTML
import MarkdownABI
import MarkdownRendering
import Unidoc
import UnidocRecords
import URI

extension Swiftinit.Stats
{
    struct ModulePage
    {
        let context:IdentifiablePageContext<Unidoc.Scalar>

        let canonical:CanonicalVersion?
        let sidebar:Swiftinit.Sidebar<Swiftinit.Stats>?

        private
        let vertex:Unidoc.CultureVertex

        init(_ context:IdentifiablePageContext<Unidoc.Scalar>,
            canonical:CanonicalVersion?,
            sidebar:Swiftinit.Sidebar<Swiftinit.Stats>?,
            vertex:Unidoc.CultureVertex)
        {
            self.context = context
            self.canonical = canonical
            self.sidebar = sidebar
            self.vertex = vertex
        }
    }
}
extension Swiftinit.Stats.ModulePage
{
    private
    var demonym:Swiftinit.ModuleDemonym
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
extension Swiftinit.Stats.ModulePage:Swiftinit.RenderablePage
{
    var title:String { "\(self.name) · \(self.volume.title) Statistics" }

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
extension Swiftinit.Stats.ModulePage:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Stats[self.volume, self.vertex.route] }
}
extension Swiftinit.Stats.ModulePage:Swiftinit.ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Swiftinit.Stats.ModulePage:Swiftinit.VertexPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        let back:String = "\(Swiftinit.Docs[self.volume, self.vertex.route])"

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

        main[.section] { $0.class = "notice canonical" } = self.canonical

        main[.section]
        {
            $0.class = "details"
        }
            content:
        {
            $0[.h2] = Swiftinit.StatsHeading.interfaceBreakdown

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

            $0[.h2] = Swiftinit.StatsHeading.documentationCoverage

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
