import HTML
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

        private
        let master:Record.Master.Culture
        private
        let groups:[Record.Group]
        private
        let nouns:[Record.Noun]?

        init(_ inliner:Inliner,
            master:Record.Master.Culture,
            groups:[Record.Group],
            nouns:[Record.Noun]?)
        {
            self.inliner = inliner
            self.master = master
            self.groups = groups
            self.nouns = nouns
        }
    }
}
extension Site.Docs.Culture
{
    private
    var zone:Record.Zone { self.inliner.zones.principal }
    private
    var name:String { self.master.module.name }
}
extension Site.Docs.Culture:FixedPage
{
    var location:URI { Site.Docs[self.zone, self.master.shoot] }
    var title:String { "\(self.name) - \(self.zone.title))" }
}
extension Site.Docs.Culture:ApplicationPage
{
    typealias Navigator = HTML.Logo

    var sidebar:Inliner.NounTree?
    {
        self.nouns.map { .init(self.inliner, nouns: $0) }
    }

    var search:URI
    {
        Site.NounMaps[self.zone]
    }

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
                        $0[.a] { $0.href = "\(Site.Docs[self.zone])" } = "\(self.zone.package)"
                    }

                    $0[.span] { $0.class = "version" } = self.zone.version
                }
            }

            $0[.h1] = self.name

            $0 ?= (self.master.overview?.markdown).map(self.inliner.passage(_:))

            if  let readme:Unidoc.Scalar = self.master.readme
            {
                $0 ?= self.inliner.link(file: readme)
            }
        }

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

        main[.section] { $0.class = "details" } =
            (self.master.details?.markdown).map(self.inliner.passage(_:))

        main += groups
    }
}
