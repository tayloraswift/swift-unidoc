import HTML
import MarkdownABI
import MarkdownRendering
import UnidocRecords
import Unidoc
import URI

extension Site.Docs
{
    struct Module
    {
        let context:IdentifiablePageContext<Unidoc.Scalar>

        let canonical:CanonicalVersion?
        let sidebar:HTML.Sidebar<Site.Docs>?

        private
        let vertex:Unidoc.Vertex.Culture
        private
        let groups:GroupSections

        init(_ context:IdentifiablePageContext<Unidoc.Scalar>,
            canonical:CanonicalVersion?,
            sidebar:HTML.Sidebar<Site.Docs>?,
            vertex:Unidoc.Vertex.Culture,
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
extension Site.Docs.Module
{
    private
    var name:String { self.vertex.module.name }

    private
    var stem:Unidoc.Stem { self.vertex.stem }
}
extension Site.Docs.Module:RenderablePage
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
extension Site.Docs.Module:StaticPage
{
    var location:URI { Site.Docs[self.volume, self.vertex.shoot] }
}
extension Site.Docs.Module:ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Site.Docs.Module:VersionedPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Module"
                $0[.span, { $0.class = "domain" }]
                {
                    $0[.span, { $0.class = "volume" }]
                    {
                        $0[.a]
                        {
                            $0.href = "\(Site.Docs[self.volume])"
                        } = "\(self.volume.symbol.package) \(self.volume.symbol.version)"
                    }

                    $0[.span] { $0.class = "jump" } = self.stem.first
                }
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
                    $0[.span] { $0.highlight = .identifier } = self.stem.first
                }
            }
        }

        main[.section]
        {
            $0.class = "details"
        }
            content:
        {
            // $0[.h2] = "Module Information"

            $0[.div, { $0.class = "more" }]
            {
                let url:String = "\(Site.Stats[self.volume, self.vertex.shoot])"

                $0[.div, { $0.class = "charts" }]
                {
                    $0[.div]
                    {
                        $0[.p]
                        {
                            let target:AutomaticHeading = .interfaceBreakdown
                            $0[.a] { $0.href = "\(url)#\(target.id)" } = "Declarations"
                        }

                        $0[.figure]
                        {
                            $0.class = "chart decl"
                        } = self.vertex.census.unweighted.decls.pie
                        {
                            """
                            \($1) percent of the declarations in \(self.name) are \($0.name)
                            """
                        }
                    }

                    $0[.div]
                    {
                        $0[.p]
                        {
                            let target:AutomaticHeading = .documentationCoverage
                            $0[.a] { $0.href = "\(url)#\(target.id)" } = "Coverage"
                        }

                        $0[.figure]
                        {
                            $0.class = "chart coverage"
                        } = self.vertex.census.unweighted.coverage.pie
                        {
                            """
                            \($1) percent of the declarations in \(self.name) are \($0.name)
                            """
                        }
                    }
                }

                $0[.a] { $0.href = url } = "Module stats and coverage details"
            }

            $0 ?= (self.vertex.details?.markdown).map(self.context.prose(_:))
        }

        main += self.groups
    }
}
