import HTML
import MarkdownABI
import MarkdownRendering
import ModuleGraphs
import UnidocRecords
import Unidoc
import URI

extension Site.Docs
{
    struct Culture
    {
        let context:IdentifiablePageContext<Unidoc.Scalar>

        let canonical:CanonicalVersion?
        let sidebar:[Volume.Noun]?

        private
        let vertex:Volume.Vertex.Culture
        private
        let groups:GroupSections

        init(_ context:IdentifiablePageContext<Unidoc.Scalar>,
            canonical:CanonicalVersion?,
            sidebar:[Volume.Noun]?,
            vertex:Volume.Vertex.Culture,
            groups:GroupSections)
        {
            self.context = context
            self.canonical = canonical
            self.sidebar = sidebar
            self.vertex = vertex
            self.groups = groups
        }
    }
}
extension Site.Docs.Culture
{
    private
    var name:String { self.vertex.module.name }
}
extension Site.Docs.Culture:RenderablePage
{
    var title:String { "\(self.name) - \(self.volume.title) Documentation" }

    var description:String?
    {
        if  let overview:MarkdownBytecode = self.vertex.overview?.markdown
        {
            "\(self.context.prose(overview))"
        }
        else if case .swift = self.volume.symbol.package
        {
            "\(self.name) is a module in the Swift standard library."
        }
        else
        {
            "\(self.name) is a module in the \(self.volume.title) package."
        }
    }
}
extension Site.Docs.Culture:StaticPage
{
    var location:URI { Site.Docs[self.volume, self.vertex.shoot] }
}
extension Site.Docs.Culture:ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Site.Docs.Culture:VersionedPage
{
    func main(_ main:inout HTML.ContentEncoder, assets:StaticAssets)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Module"
                $0[.span] { $0.class = "domain" } = self.volume.domain
            }

            $0[.h1] = self.name

            $0 ?= (self.vertex.overview?.markdown).map(self.context.prose(_:))

            if  let readme:Unidoc.Scalar = self.vertex.readme
            {
                $0 ?= self.context.link(file: readme)
            }
        }

        main[.section] { $0.class = "notice canonical" } = self.canonical

        main[.section, { $0.class = "declaration" }]
        {
            $0[.pre]
            {
                $0[.code]
                {
                    $0[.span] { $0.highlight = .keyword } = "import"
                    $0 += " "
                    $0[.span] { $0.highlight = .identifier } = self.vertex.module.id
                }
            }
        }

        main[.section]
        {
            $0.class = "details"
        }
            content:
        {
            $0[.div, { $0.class = "stats"}]
            {
                $0[.h2] = "Interface Breakdown"

                $0 += Unidoc.StatsBreakdown.init(
                    unweighted: self.vertex.census.unweighted.decls,
                    weighted: self.vertex.census.weighted.decls,
                    domain: "this module").condensed


                $0[.h2] = "Doc Coverage"

                $0 += Unidoc.StatsBreakdown.init(
                    unweighted: self.vertex.census.unweighted.coverage,
                    weighted: self.vertex.census.weighted.coverage,
                    domain: "this module").condensed
            }

            $0 ?= (self.vertex.details?.markdown).map(self.context.prose(_:))
        }

        main += self.groups
    }
}
