import HTML
import MarkdownABI
import MarkdownRendering
import UnidocRecords
import Unidoc
import URI

extension Swiftinit.Stats
{
    struct Package
    {
        let context:IdentifiablePageContext<Unidoc.Scalar>

        let canonical:CanonicalVersion?
        let sidebar:Swiftinit.Sidebar<Swiftinit.Stats>?

        private
        let vertex:Unidoc.Vertex.Global

        init(_ context:IdentifiablePageContext<Unidoc.Scalar>,
            canonical:CanonicalVersion?,
            sidebar:Swiftinit.Sidebar<Swiftinit.Stats>?,
            vertex:Unidoc.Vertex.Global)
        {
            self.context = context
            self.canonical = canonical
            self.sidebar = sidebar
            self.vertex = vertex
        }
    }
}
extension Swiftinit.Stats.Package:Swiftinit.RenderablePage
{
    var title:String { "\(self.volume.title) Statistics" }

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
extension Swiftinit.Stats.Package:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Stats[self.volume] }
}
extension Swiftinit.Stats.Package:Swiftinit.ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Swiftinit.Stats.Package:Swiftinit.VersionedPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        let back:String = "\(Swiftinit.Docs[self.volume])"

        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Package details"
                $0[.span, { $0.class = "domain" }] = self.context.domain
            }

            $0[.h1] = "\(self.volume.title) metrics"

            $0[.p]
            {
                $0 += "Statistics and coverage details for the "
                $0[.a] { $0.href = back } = self.volume.title
                $0 += " package."
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

            let coverage:AutomaticHeading = .documentationCoverage
            $0[.h2] { $0.id = coverage.id } = coverage

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

            $0[.h3] = "Symbols"
            $0[.figure]
            {
                $0.class = "chart coverage"
            } = self.vertex.snapshot.census.weighted.coverage.chart
            {
                """
                \($1) percent of the symbols in \(self.volume.title) are \($0.name)
                """
            }
        }
    }
}
