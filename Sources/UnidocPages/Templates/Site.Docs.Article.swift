import HTML
import MarkdownRendering
import UnidocRecords
import Unidoc
import URI

extension Site.Docs
{
    struct Article
    {
        private
        let inliner:Inliner

        private
        let master:Record.Master.Article
        private
        let groups:[Record.Group]
        private
        let nouns:[Record.Noun]


        init(_ inliner:Inliner,
            master:Record.Master.Article,
            groups:[Record.Group],
            nouns:[Record.Noun])
        {
            self.inliner = inliner
            self.master = master
            self.groups = groups
            self.nouns = nouns
        }
    }
}
extension Site.Docs.Article
{
    private
    var stem:Record.Stem { self.master.stem }
}
extension Site.Docs.Article:FixedPage
{
    var location:URI { Site.Docs[self.zone, self.master.shoot] }

    var title:String { self.zone.title }

    var zone:Record.Zone { self.inliner.zones.principal }

    var sidebar:Inliner.NounTree?
    {
        .init(self.inliner, nouns: self.nouns)
    }

    func emit(content html:inout HTML.ContentEncoder)
    {
        let groups:Inliner.Groups = .init(inliner,
            groups: self.groups,
            bias: self.master.id,
            mode: nil)

        html[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Article"

                $0[.span, { $0.class = "module" }]
                {
                    $0[link: self.inliner.url(self.master.culture)] = self.stem.first

                    $0[.span, { $0.class = "culture" }]
                    {
                        $0[.span] { $0.class = "version" } = self.zone.version
                    }
                }
            }

            $0[.h1] = self.master.headline.safe

            $0 ?= (self.master.overview?.markdown).map(self.inliner.passage(_:))

            if  let file:Unidoc.Scalar = self.master.file
            {
                $0 ?= self.inliner.link(file: file)
            }
        }

        html[.section, { $0.class = "details" }] =
            (self.master.details?.markdown).map(self.inliner.passage(_:))

        html += groups
    }
}
