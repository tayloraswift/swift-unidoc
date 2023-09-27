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
        let inliner:Inliner

        let canonical:CanonicalVersion?
        private
        let master:Volume.Vertex.Culture
        private
        let groups:[Volume.Group]
        private
        let nouns:[Volume.Noun]?

        init(_ inliner:Inliner,
            canonical:CanonicalVersion?,
            master:Volume.Vertex.Culture,
            groups:[Volume.Group],
            nouns:[Volume.Noun]?)
        {
            self.inliner = inliner
            self.canonical = canonical
            self.master = master
            self.groups = groups
            self.nouns = nouns
        }
    }
}
extension Site.Docs.Culture
{
    private
    var names:Volume.Meta { self.inliner.names.principal }
    private
    var name:String { self.master.module.name }
}
extension Site.Docs.Culture:RenderablePage
{
    var title:String { "\(self.name) - \(self.names.title)" }

    var description:String?
    {
        if  let overview:MarkdownBytecode = self.master.overview?.markdown
        {
            return "\(self.inliner.passage(overview))"
        }
        else if case .swift = self.names.package
        {
            return "\(self.name) is a module in the Swift standard library."
        }
        else
        {
            return """
                \(self.name) is a module in the \
                \(self.names.display ?? "\(self.names.package)") package.
                """
        }
    }
}
extension Site.Docs.Culture:StaticPage
{
    var location:URI { Site.Docs[self.names, self.master.shoot] }
}
extension Site.Docs.Culture:ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Site.Docs.Culture:VersionedPage
{
    var sidebar:Inliner.TypeTree? { self.nouns.map { .init(self.inliner, nouns: $0) } }

    var volume:VolumeIdentifier { self.names.volume }

    func main(_ main:inout HTML.ContentEncoder)
    {
        let groups:Inliner.Groups = .init(inliner,
            groups: self.groups,
            bias: self.master.id,
            mode: nil)

        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Module"
                $0[.span, { $0.class = "domain" }]
                {
                    $0[.span, { $0.class = "package" }]
                    {
                        $0[.a]
                        {
                            $0.href = "\(Site.Docs[self.names])"
                        } = "\(self.names.package)"
                    }

                    $0[.span] { $0.class = "version" } = self.names.version
                }
            }

            $0[.h1] = self.name

            $0 ?= (self.master.overview?.markdown).map(self.inliner.passage(_:))

            if  let readme:Unidoc.Scalar = self.master.readme
            {
                $0 ?= self.inliner.link(file: readme)
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
                    $0[.span] { $0.highlight = .identifier } = self.master.module.id
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
                    unweighted: self.master.census.unweighted.decls,
                    weighted: self.master.census.weighted.decls,
                    domain: "this module").condensed


                $0[.h2] = "Doc Coverage"

                $0 += Unidoc.StatsBreakdown.init(
                    unweighted: self.master.census.unweighted.coverage,
                    weighted: self.master.census.weighted.coverage,
                    domain: "this module").condensed
            }

            $0 ?= (self.master.details?.markdown).map(self.inliner.passage(_:))
        }

        main += groups
    }
}
